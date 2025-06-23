# frozen_string_literal: true

class Item < ApplicationRecord
  include PgSearch::Model

  # Search configuration
  pg_search_scope :search_by_details,
                  against: [:name, :serial_number, :category, :brand, :model, :description],
                  using: {
                    tsearch: { prefix: true, any_word: true },
                    trigram: { threshold: 0.3 }
                  }

  # Associations
  belongs_to :warehouse
  has_many :transactions, dependent: :destroy
  has_many :checkout_transactions, -> { where(action_type: 'out') }, class_name: 'Transaction'
  has_many :checkin_transactions, -> { where(action_type: 'in') }, class_name: 'Transaction'

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :category, presence: true, length: { minimum: 2, maximum: 50 }
  validates :qr_code, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[stokta kullanımda bakımda] }
  validates :serial_number, uniqueness: { allow_blank: true }
  validates :value, numericality: { greater_than: 0, allow_nil: true }

  # Callbacks
  before_validation :generate_qr_code, on: :create
  after_create :generate_qr_code_image
  after_update :check_and_update_overdue_transactions

  # Enums
  enum status: { stokta: 'stokta', kullanımda: 'kullanımda', bakımda: 'bakımda' }

  # Scopes
  scope :in_stock, -> { where(status: 'stokta') }
  scope :in_use, -> { where(status: 'kullanımda') }
  scope :in_maintenance, -> { where(status: 'bakımda') }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_brand, ->(brand) { where(brand: brand) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_warehouse, ->(warehouse_id) { where(warehouse_id: warehouse_id) }
  scope :with_value, -> { where.not(value: nil) }
  scope :overdue, -> { joins(:transactions).where(transactions: { status: 'overdue' }) }
  scope :search_items, ->(query) { search_by_details(query) }
  scope :recent, -> { order(created_at: :desc) }

  # Class methods
  def self.categories
    distinct.pluck(:category).compact.sort
  end

  def self.brands
    distinct.pluck(:brand).compact.sort
  end

  def self.statuses_with_colors
    {
      'stokta' => 'success',
      'kullanımda' => 'warning',
      'bakımda' => 'danger'
    }
  end

  # Instance methods
  def status_color
    case status
    when 'stokta'
      'green'
    when 'kullanımda'
      'orange'
    when 'bakımda'
      'red'
    else
      'gray'
    end
  end

  def status_icon
    case status
    when 'stokta'
      'check-circle'
    when 'kullanımda'
      'arrow-right-circle'
    when 'bakımda'
      'tool'
    else
      'question-circle'
    end
  end

  def current_transaction
    transactions.where(status: ['active', 'overdue']).order(created_at: :desc).first
  end

  def last_checkout
    checkout_transactions.order(created_at: :desc).first
  end

  def last_checkin
    checkin_transactions.order(created_at: :desc).first
  end

  def is_overdue?
    current_transaction&.overdue?
  end

  def days_until_return
    return nil unless current_transaction&.return_date
    (current_transaction.return_date.to_date - Date.current).to_i
  end

  def days_overdue
    return 0 unless is_overdue?
    return 0 unless current_transaction.return_date
    (Date.current - current_transaction.return_date.to_date).to_i
  end

  def status_label
    case status
    when 'stokta'
      'Stokta'
    when 'kullanımda'
      'Kullanımda'
    when 'bakımda'
      'Bakımda'
    else
      status.humanize
    end
  end

  def available_for_checkout?
    status == 'stokta'
  end

  def checked_out?
    status == 'kullanımda'
  end

  def current_location_info
    if status == 'stokta'
      "#{warehouse.name} - #{warehouse.location}"
    elsif current_transaction
      current_transaction.destination || 'Bilinmeyen konum'
    else
      'Konum bilinmiyor'
    end
  end

  def active_transactions
    transactions.where(status: ['active', 'overdue'])
  end

  def days_checked_out
    return 0 unless current_transaction
    (Date.current - current_transaction.created_at.to_date).to_i
  end

  def overdue_transactions_count
    transactions.where(status: 'overdue').count
  end

  def can_checkout?
    status == 'stokta'
  end

  def can_checkin?
    status == 'kullanımda' && current_transaction.present?
  end

  def can_send_to_maintenance?
    status == 'stokta'
  end

  def can_return_from_maintenance?
    status == 'bakımda'
  end

  def checkout!(user:, destination:, return_date: nil, notes: nil, checkout_reason: nil)
    return false unless can_checkout?

    transaction = nil
    ActiveRecord::Base.transaction do
      transaction = transactions.create!(
        user: user,
        warehouse: warehouse,
        action_type: 'out',
        destination: destination,
        return_date: return_date,
        notes: notes,
        checkout_reason: checkout_reason,
        status: 'active'
      )

      update!(status: 'kullanımda')
    end

    transaction
  end

  def checkin!(user:, notes: nil)
    return false unless can_checkin?

    current_trans = current_transaction
    return false unless current_trans

    ActiveRecord::Base.transaction do
      current_trans.update!(
        actual_return_date: Time.current,
        status: 'completed'
      )

      transactions.create!(
        user: user,
        warehouse: warehouse,
        action_type: 'in',
        checkin_notes: notes,
        status: 'completed'
      )

      update!(status: 'stokta')
    end

    true
  end

  def send_to_maintenance!(user:, notes: nil)
    return false unless can_send_to_maintenance?

    ActiveRecord::Base.transaction do
      transactions.create!(
        user: user,
        warehouse: warehouse,
        action_type: 'out',
        destination: 'Bakım',
        checkout_reason: 'Bakım için çıkarıldı',
        notes: notes,
        status: 'active'
      )

      update!(status: 'bakımda')
    end

    true
  end

  def return_from_maintenance!(user:, notes: nil)
    return false unless can_return_from_maintenance?

    current_trans = current_transaction

    ActiveRecord::Base.transaction do
      current_trans&.update!(
        actual_return_date: Time.current,
        status: 'completed'
      )

      transactions.create!(
        user: user,
        warehouse: warehouse,
        action_type: 'in',
        checkin_notes: notes || 'Bakımdan geri döndü',
        status: 'completed'
      )

      update!(status: 'stokta')
    end

    true
  end

  def qr_code_url
    return nil unless qr_code.present?
    "/qr_codes/items/#{qr_code}.png"
  end

  def qr_code_pdf_url
    return nil unless qr_code.present?
    "/api/v1/items/#{id}/qr_code_pdf"
  end

  def display_name
    parts = [name]
    parts << "(#{brand})" if brand.present?
    parts << "- #{model}" if model.present?
    parts.join(' ')
  end

  def full_description
    parts = [display_name]
    parts << "S/N: #{serial_number}" if serial_number.present?
    parts << "Kategori: #{category}"
    parts << "Konum: #{warehouse.display_name}"
    parts.join(' | ')
  end

  def transaction_history
    transactions.includes(:user, :warehouse).order(created_at: :desc)
  end

  def total_checkout_days
    checkout_transactions.where.not(actual_return_date: nil)
                        .sum { |t| (t.actual_return_date.to_date - t.created_at.to_date).to_i }
  end

  def usage_frequency
    checkout_transactions.count
  end

  def is_warranty_valid?
    return false unless warranty_date
    warranty_date > Date.current
  end

  def warranty_days_remaining
    return 0 unless is_warranty_valid?
    (warranty_date - Date.current).to_i
  end

  def value_formatted
    return 'Belirtilmemiş' unless value
    "₺#{value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}"
  end

  def summary_info
    {
      name: name,
      status: status,
      status_color: status_color,
      warehouse: warehouse.display_name,
      current_user: current_transaction&.user&.name,
      days_until_return: days_until_return,
      is_overdue: is_overdue?,
      days_overdue: days_overdue
    }
  end

  def to_s
    name
  end

  private

  def generate_qr_code
    return if qr_code.present?

    loop do
      self.qr_code = "IT-#{SecureRandom.alphanumeric(8).upcase}"
      break unless self.class.exists?(qr_code: qr_code)
    end
  end

  def generate_qr_code_image
    return unless qr_code.present?

    qr = RQRCode::QRCode.new("#{Rails.application.routes.url_helpers.root_url}scan/#{qr_code}")

    # Generate PNG
    png = qr.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 300,
      border_modules: 1,
      module_px_size: 3
    )

    # Create directory if it doesn't exist
    qr_dir = Rails.root.join('public', 'qr_codes', 'items')
    FileUtils.mkdir_p(qr_dir)

    # Save QR code image
    qr_path = qr_dir.join("#{qr_code}.png")
    File.open(qr_path, 'wb') { |f| f << png.to_s }

    # Update qr_code_url
    update_column(:qr_code_url, "/qr_codes/items/#{qr_code}.png")
  rescue => e
    Rails.logger.error "Failed to generate QR code for item #{id}: #{e.message}"
  end

  def check_and_update_overdue_transactions
    return unless status_changed?

    # If item is checked back in, mark overdue transactions as completed
    if status == 'stokta' && status_was == 'kullanımda'
      overdue_transactions = transactions.where(status: 'overdue', action_type: 'out')
      overdue_transactions.update_all(
        status: 'completed',
        actual_return_date: Time.current
      )
    end
  end
end
