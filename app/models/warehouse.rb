# frozen_string_literal: true

class Warehouse < ApplicationRecord
  include PgSearch::Model

  # Search configuration
  pg_search_scope :search_by_name_and_location,
                  against: [:name, :location, :description],
                  using: {
                    tsearch: { prefix: true, any_word: true },
                    trigram: { threshold: 0.3 }
                  }

  # Associations
  has_many :items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :location, presence: true, length: { minimum: 5, maximum: 255 }
  validates :qr_code, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active inactive] }
  validates :capacity, numericality: { greater_than: 0, allow_nil: true }

  # Callbacks
  before_validation :generate_qr_code, on: :create
  after_create :generate_qr_code_image

  # Enums
  enum status: { active: 'active', inactive: 'inactive' }

  # Scopes
  scope :active_warehouses, -> { where(status: 'active') }
  scope :with_capacity, -> { where.not(capacity: nil) }
  scope :by_location, ->(location) { where('location ILIKE ?', "%#{location}%") }

  # Instance methods
  def total_items
    items.count
  end

  def items_in_stock
    items.where(status: 'stokta').count
  end

  def items_in_use
    items.where(status: 'kullanımda').count
  end

  def items_in_maintenance
    items.where(status: 'bakımda').count
  end

  def occupancy_rate
    return 0 if capacity.nil? || capacity.zero?
    (total_items.to_f / capacity * 100).round(2)
  end

  def available_capacity
    return nil if capacity.nil?
    [capacity - total_items, 0].max
  end

  def is_full?
    return false if capacity.nil?
    total_items >= capacity
  end

  def can_add_items?(count = 1)
    return true if capacity.nil?
    (total_items + count) <= capacity
  end

  def status_color
    case status
    when 'active'
      'green'
    when 'inactive'
      'red'
    else
      'gray'
    end
  end

  def recent_transactions(limit = 10)
    transactions.includes(:item, :user).order(created_at: :desc).limit(limit)
  end

  def qr_code_url
    return nil unless qr_code.present?
    "/qr_codes/warehouses/#{qr_code}.png"
  end

  def qr_code_pdf_url
    return nil unless qr_code.present?
    "/api/v1/warehouses/#{id}/qr_code_pdf"
  end

  def display_name
    "#{name} - #{location}"
  end

  def summary_stats
    {
      total_items: total_items,
      items_in_stock: items_in_stock,
      items_in_use: items_in_use,
      items_in_maintenance: items_in_maintenance,
      occupancy_rate: occupancy_rate,
      available_capacity: available_capacity,
      is_full: is_full?
    }
  end

  def to_s
    name
  end

  private

  def generate_qr_code
    return if qr_code.present?

    loop do
      self.qr_code = "WH-#{SecureRandom.alphanumeric(8).upcase}"
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
    qr_dir = Rails.root.join('public', 'qr_codes', 'warehouses')
    FileUtils.mkdir_p(qr_dir)

    # Save QR code image
    qr_path = qr_dir.join("#{qr_code}.png")
    File.open(qr_path, 'wb') { |f| f << png.to_s }

    # Update qr_code_url
    update_column(:qr_code_url, "/qr_codes/warehouses/#{qr_code}.png")
  rescue => e
    Rails.logger.error "Failed to generate QR code for warehouse #{id}: #{e.message}"
  end
end
