# frozen_string_literal: true

class Transaction < ApplicationRecord
  # Associations
  belongs_to :item
  belongs_to :user
  belongs_to :warehouse, optional: true

  # Validations
  validates :action_type, presence: true, inclusion: { in: %w[in out] }
  validates :status, presence: true, inclusion: { in: %w[active completed overdue] }
  validates :destination, presence: true, if: -> { action_type == 'out' }
  validates :return_date, presence: true, if: -> { action_type == 'out' && status == 'active' }

  # Callbacks
  after_create :check_overdue_status
  after_update :update_item_status_if_needed

  # Enums
  enum action_type: { out: 'out', in: 'in' }
  enum status: { active: 'active', completed: 'completed', overdue: 'overdue' }

  # Scopes
  scope :checkouts, -> { where(action_type: 'out') }
  scope :checkins, -> { where(action_type: 'in') }
  scope :checkout, -> { where(action_type: 'out') }
  scope :checkin, -> { where(action_type: 'in') }
  scope :active_checkouts, -> { where(action_type: 'out', status: ['active', 'overdue']) }
  scope :overdue_checkouts, -> { where(action_type: 'out', status: 'overdue') }
  scope :overdue, -> { where(status: 'overdue') }
  scope :completed_transactions, -> { where(status: 'completed') }
  scope :completed_today, -> { where(status: 'completed', created_at: Date.current.all_day) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_item, ->(item_id) { where(item_id: item_id) }
  scope :by_warehouse, ->(warehouse) { where(warehouse: warehouse) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_action_type, ->(action_type) { where(action_type: action_type) }
  scope :in_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Class methods
  def self.overdue_items
    where(action_type: 'out', status: 'active')
      .where('return_date < ?', Time.current)
  end

  def self.update_overdue_statuses!
    overdue_count = overdue_items.update_all(status: 'overdue')
    Rails.logger.info "Updated #{overdue_count} transactions to overdue status"
    overdue_count
  end

  def self.summary_stats
    {
      total_transactions: count,
      active_checkouts: active_checkouts.count,
      overdue_checkouts: overdue_checkouts.count,
      completed_today: completed_transactions.where(created_at: Date.current.all_day).count,
      total_value_out: joins(:item).where(action_type: 'out', status: ['active', 'overdue'])
                                   .sum('items.value') || 0
    }
  end

  # Instance methods
  def checkout?
    action_type == 'out'
  end

  def checkin?
    action_type == 'in'
  end

  def overdue?
    return false unless checkout?
    return false unless return_date
    return false if completed?

    return_date < Time.current
  end

  def days_overdue
    return 0 unless overdue?
    (Date.current - return_date.to_date).to_i
  end

  def days_until_return
    return nil unless return_date
    return nil if completed?
    (return_date.to_date - Date.current).to_i
  end

  def duration_days
    return nil unless completed? && actual_return_date
    (actual_return_date.to_date - created_at.to_date).to_i
  end

  def is_late_return?
    return false unless completed? && actual_return_date && return_date
    actual_return_date > return_date
  end

  def late_days
    return 0 unless is_late_return?
    (actual_return_date.to_date - return_date.to_date).to_i
  end

  def status_color
    case status
    when 'active'
      overdue? ? 'red' : 'orange'
    when 'completed'
      is_late_return? ? 'yellow' : 'green'
    when 'overdue'
      'red'
    else
      'gray'
    end
  end

  def status_label
    case status
    when 'active'
      overdue? ? 'Gecikmiş' : 'Aktif'
    when 'completed'
      is_late_return? ? 'Geç Teslim' : 'Tamamlandı'
    when 'overdue'
      'Gecikmiş'
    else
      status.humanize
    end
  end

  def action_label
    case action_type
    when 'out'
      'Çıkış'
    when 'in'
      'Giriş'
    else
      action_type.humanize
    end
  end

  def can_complete?
    active? && checkout?
  end

  def can_extend_return_date?
    active? && checkout? && !overdue?
  end

  def extend_return_date!(new_date, user: nil, notes: nil)
    return false unless can_extend_return_date?
    return false if new_date <= return_date

    old_date = return_date
    update!(
      return_date: new_date,
      notes: [notes, "Dönüş tarihi #{old_date.strftime('%d.%m.%Y')} tarihinden #{new_date.strftime('%d.%m.%Y')} tarihine uzatıldı."].compact.join(' - ')
    )

    true
  end

  def complete!(actual_return_date: Time.current, notes: nil)
    return false unless can_complete?

    update!(
      actual_return_date: actual_return_date,
      status: 'completed',
      checkin_notes: notes
    )

    # Update item status back to in stock
    item.update!(status: 'stokta') if item.status == 'kullanımda'

    true
  end

  def description
    if checkout?
      parts = ["#{item.name} çıkış"]
      parts << "→ #{destination}" if destination.present?
      parts << "(#{user.name})" if user
      parts.join(' ')
    else
      parts = ["#{item.name} giriş"]
      parts << "(#{user.name})" if user
      parts.join(' ')
    end
  end

  def full_description
    parts = [description]
    parts << "Dönüş: #{return_date.strftime('%d.%m.%Y')}" if return_date && checkout?
    parts << "Durum: #{status_label}"
    parts << "Gecikme: #{days_overdue} gün" if overdue?
    parts.join(' | ')
  end

  def to_s
    description
  end

  private

  def check_overdue_status
    return unless checkout? && return_date

    # Schedule a job to check overdue status
    # For now, we'll use a simple callback
    CheckOverdueTransactionsJob.set(wait_until: return_date).perform_later if defined?(CheckOverdueTransactionsJob)
  end

  def update_item_status_if_needed
    return unless saved_change_to_status?

    case status
    when 'completed'
      if action_type == 'in'
        item.update!(status: 'stokta')
      end
    when 'overdue'
      if action_type == 'out'
        item.update!(status: 'kullanımda') unless item.status == 'kullanımda'
      end
    end
  end
end
