# frozen_string_literal: true

class Api::V1::QrScannerController < Api::V1::BaseController

  # POST /api/v1/qr_scanner/scan
  def scan
    qr_code = params[:qr_code]&.strip&.upcase

    if qr_code.blank?
      render_error('QR kod gerekli', status: :unprocessable_entity)
      return
    end

    scan_result = process_qr_scan(qr_code)

    if scan_result
      # Log the scan activity
      log_scan_activity(qr_code, scan_result[:type], scan_result[:id])

      render_success(scan_result)
    else
      render_error('QR kod tanınamadı veya bulunamadı', status: :not_found)
    end
  end

  # POST /api/v1/qr_scanner/quick_action
  def quick_action
    qr_code = params[:qr_code]&.strip&.upcase
    action = params[:action]&.strip&.downcase

    if qr_code.blank? || action.blank?
      render_error('QR kod ve aksiyon gerekli', status: :unprocessable_entity)
      return
    end

    result = perform_quick_action(qr_code, action)

    if result[:success]
      render_success(result[:data], message: result[:message])
    else
      render_error(result[:error], status: result[:error_code] || :unprocessable_entity)
    end
  end

  # GET /api/v1/qr_scanner/history
  def scan_history
    scans = current_user.scan_activities
                       .includes(:scannable)
                       .order(created_at: :desc)
                       .limit(50)

    render_collection(scans.map { |scan| scan_history_data(scan) })
  end

  # POST /api/v1/qr_scanner/bulk_scan
  def bulk_scan
    qr_codes = params[:qr_codes]

    if qr_codes.blank? || !qr_codes.is_a?(Array)
      render_error('QR kod listesi gerekli', status: :unprocessable_entity)
      return
    end

    results = process_bulk_scan(qr_codes)

    render_success({
      total_scanned: qr_codes.length,
      successful_scans: results[:successful].length,
      failed_scans: results[:failed].length,
      results: {
        successful: results[:successful],
        failed: results[:failed]
      }
    })
  end

  private

  def process_qr_scan(qr_code)
    # Try to find item first
    if qr_code.start_with?('IT-')
      item = Item.find_by(qr_code: qr_code)
      return item_scan_data(item) if item
    end

    # Try to find warehouse
    if qr_code.start_with?('WH-')
      warehouse = Warehouse.find_by(qr_code: qr_code)
      return warehouse_scan_data(warehouse) if warehouse
    end

    # Try both if format is unclear
    item = Item.find_by(qr_code: qr_code)
    return item_scan_data(item) if item

    warehouse = Warehouse.find_by(qr_code: qr_code)
    return warehouse_scan_data(warehouse) if warehouse

    nil
  end

  def perform_quick_action(qr_code, action)
    scan_result = process_qr_scan(qr_code)

    unless scan_result
      return { success: false, error: 'QR kod bulunamadı', error_code: :not_found }
    end

    case scan_result[:type]
    when 'item'
      perform_item_action(scan_result[:id], action)
    when 'warehouse'
      perform_warehouse_action(scan_result[:id], action)
    else
      { success: false, error: 'Desteklenmeyen QR kod türü', error_code: :unprocessable_entity }
    end
  end

  def perform_item_action(item_id, action)
    item = Item.find(item_id)

    case action
    when 'checkout'
      if item.status == 'stokta'
        Transaction.create!(
          item: item,
          user: current_user,
          action_type: 'checkout',
          destination: 'QR ile hızlı çıkış',
          return_date: 1.week.from_now,
          status: 'active'
        )
        item.update!(status: 'kullanımda')
        {
          success: true,
          message: "#{item.name} başarıyla çıkış yapıldı",
          data: item_scan_data(item.reload)
        }
      else
        { success: false, error: 'Bu eşya çıkış için uygun değil' }
      end

    when 'info'
      {
        success: true,
        message: "#{item.name} bilgileri",
        data: item_scan_data(item)
      }

    else
      { success: false, error: 'Geçersiz aksiyon' }
    end
  end

  def perform_warehouse_action(warehouse_id, action)
    warehouse = Warehouse.find(warehouse_id)

    case action
    when 'info'
      {
        success: true,
        message: "#{warehouse.name} bilgileri",
        data: warehouse_scan_data(warehouse)
      }
    when 'items'
      {
        success: true,
        message: "#{warehouse.name} eşyaları",
        data: warehouse_scan_data(warehouse).merge(
          items: warehouse.items.limit(20).map { |item| basic_item_data(item) }
        )
      }
    else
      { success: false, error: 'Geçersiz aksiyon' }
    end
  end

  def process_bulk_scan(qr_codes)
    successful = []
    failed = []

    qr_codes.each do |qr_code|
      qr_code = qr_code.to_s.strip.upcase
      next if qr_code.blank?

      scan_result = process_qr_scan(qr_code)

      if scan_result
        successful << scan_result
        log_scan_activity(qr_code, scan_result[:type], scan_result[:id])
      else
        failed << { qr_code: qr_code, error: 'QR kod bulunamadı' }
      end
    end

    { successful: successful, failed: failed }
  end

  def log_scan_activity(qr_code, scannable_type, scannable_id)
    # Create scan activity log (you might want to create a ScanActivity model)
    Rails.logger.info "QR Scan: #{current_user.email} scanned #{qr_code} (#{scannable_type}:#{scannable_id})"

    # If you have a ScanActivity model:
    # ScanActivity.create!(
    #   user: current_user,
    #   qr_code: qr_code,
    #   scannable_type: scannable_type.classify,
    #   scannable_id: scannable_id,
    #   scanned_at: Time.current
    # )
  end

  def item_scan_data(item)
    {
      type: 'item',
      id: item.id,
      qr_code: item.qr_code,
      name: item.name,
      description: item.description,
      category: item.category,
      brand: item.brand,
      status: item.status,
      warehouse: item.warehouse ? {
        id: item.warehouse.id,
        name: item.warehouse.name,
        location: item.warehouse.location
      } : nil,
      current_location: item.current_location_info,
      available_actions: available_item_actions(item),
      last_transaction: item.transactions.recent.first&.then { |t|
        {
          id: t.id,
          action_type: t.action_type,
          action_label: t.action_label,
          user_name: t.user.name,
          created_at: t.created_at
        }
      }
    }
  end

  def warehouse_scan_data(warehouse)
    {
      type: 'warehouse',
      id: warehouse.id,
      qr_code: warehouse.qr_code,
      name: warehouse.name,
      location: warehouse.location,
      description: warehouse.description,
      status: warehouse.status,
      capacity: warehouse.capacity,
      current_items: warehouse.items.count,
      available_space: warehouse.available_capacity,
      utilization_percentage: warehouse.utilization_percentage,
      available_actions: available_warehouse_actions(warehouse),
      recent_activity: warehouse.recent_transactions(3).map { |t|
        {
          id: t.id,
          action_type: t.action_type,
          item_name: t.item.name,
          user_name: t.user.name,
          created_at: t.created_at
        }
      }
    }
  end

  def available_item_actions(item)
    actions = []

    if item.available_for_checkout?
      actions << {
        type: 'checkout',
        label: 'Hızlı Çıkış',
        icon: 'arrow-right',
        description: 'Eşyayı 1 haftalığına çıkış yap'
      }
    end

    if item.checked_out?
      actions << {
        type: 'checkin',
        label: 'Hızlı Giriş',
        icon: 'arrow-left',
        description: 'Eşyayı giriş yap'
      }
    end

    actions << {
      type: 'info',
      label: 'Detaylı Bilgi',
      icon: 'info',
      description: 'Eşya detaylarını ve geçmişini görüntüle'
    }

    actions
  end

  def available_warehouse_actions(warehouse)
    actions = [
      {
        type: 'info',
        label: 'Depo Bilgileri',
        icon: 'info',
        description: 'Depo detaylarını görüntüle'
      },
      {
        type: 'items',
        label: 'Eşyaları Listele',
        icon: 'list',
        description: 'Depodaki eşyaları görüntüle'
      }
    ]

    actions
  end

  def basic_item_data(item)
    {
      id: item.id,
      name: item.name,
      status: item.status,
      status_label: item.status_label,
      status_color: item.status_color,
      category: item.category,
      brand: item.brand
    }
  end

  def scan_history_data(scan)
    {
      id: scan.id,
      qr_code: scan.qr_code,
      scannable_type: scan.scannable_type,
      scannable_name: scan.scannable.name,
      scanned_at: scan.scanned_at,
      created_at: scan.created_at
    }
  end
end
