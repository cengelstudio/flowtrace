# frozen_string_literal: true

class QrCodeGeneratorService
  require 'rqrcode'

  def initialize(object)
    @object = object
  end

  def generate_qr_code
    qr_code = generate_unique_code
    qr_png_path = generate_qr_image(qr_code)

    @object.update!(qr_code: qr_code)

    {
      qr_code: qr_code,
      image_path: qr_png_path,
      url: qr_code_url(qr_code)
    }
  end

  private

  def generate_unique_code
    loop do
      code = case @object
             when Warehouse
               "WH-#{SecureRandom.hex(4).upcase}"
             when Item
               "IT-#{SecureRandom.hex(4).upcase}"
             else
               raise "Unsupported object type: #{@object.class}"
             end

      # Check uniqueness
      break code unless code_exists?(code)
    end
  end

  def code_exists?(code)
    Warehouse.exists?(qr_code: code) || Item.exists?(qr_code: code)
  end

  def generate_qr_image(qr_code)
    # Create QR code object
    qrcode = RQRCode::QRCode.new(qr_code)

    # Generate PNG
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 300
    )

    # Ensure directory exists
    dir_path = Rails.root.join('public', 'qr_codes', folder_name)
    FileUtils.mkdir_p(dir_path)

    # Save PNG file
    file_path = dir_path.join("#{qr_code}.png")
    png.save(file_path)

    file_path.to_s
  end

  def folder_name
    case @object
    when Warehouse
      'warehouses'
    when Item
      'items'
    else
      'others'
    end
  end

  def qr_code_url(qr_code)
    Rails.application.routes.url_helpers.url_for(
      controller: 'qr_codes',
      action: 'show',
      id: qr_code,
      only_path: true
    )
  rescue
    "/qr_codes/#{qr_code}"
  end
end
