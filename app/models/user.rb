# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # Enums
  enum role: { staff: 'staff', admin: 'admin' }

  # Associations
  has_many :transactions, dependent: :destroy
  has_many :checkout_transactions, -> { where(action_type: 'out') }, class_name: 'Transaction'
  has_many :checkin_transactions, -> { where(action_type: 'in') }, class_name: 'Transaction'

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true, inclusion: { in: roles.keys }

  # Callbacks
  before_save :normalize_email

  # Scopes
  scope :admins, -> { where(role: 'admin') }
  scope :staff, -> { where(role: 'staff') }
  scope :active, -> { where(locked_at: nil) }

  # Instance methods
  def admin?
    role == 'admin'
  end

  def staff?
    role == 'staff'
  end

  def can_manage_users?
    admin?
  end

  def can_view_reports?
    admin?
  end

  def can_manage_warehouses?
    admin?
  end

  def can_manage_items?
    true # Both admin and staff can manage items
  end

  def can_scan_qr_codes?
    true # Both admin and staff can scan QR codes
  end

  def full_name
    name
  end

  def display_name
    "#{name} (#{role.capitalize})"
  end

  def recent_transactions(limit = 10)
    transactions.order(created_at: :desc).limit(limit)
  end

  def active_checkouts
    checkout_transactions.where(status: ['active', 'overdue'])
  end

  def overdue_checkouts
    checkout_transactions.where(status: 'overdue')
  end

  def total_transactions_count
    transactions.count
  end

  def to_s
    name
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
