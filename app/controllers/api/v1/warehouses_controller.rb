# frozen_string_literal: true

class Api::V1::WarehousesController < Api::V1::BaseController
  before_action :set_warehouse, only: [:show, :update, :destroy, :qr_code, :qr_code_pdf]
  before_action :require_admin!, only: [:create, :update, :destroy]

  # GET /api/v1/warehouses
  def index
    @warehouses = Warehouse.active_warehouses
                          .includes(:items)
                          .order(:name)

    # Search functionality
    if params[:search].present?
      @warehouses = @warehouses.search_by_name_and_location(params[:search])
    end

    # Filter by location
    if params[:location].present?
      @warehouses = @warehouses.by_location(params[:location])
    end

    render_collection(@warehouses.map { |w| warehouse_data(w) })
  end

  # GET /api/v1/warehouses/:id
  def show
    render_success(warehouse_detail_data(@warehouse))
  end

  # POST /api/v1/warehouses
  def create
    @warehouse = Warehouse.new(warehouse_params)

    if @warehouse.save
      render_success(
        warehouse_data(@warehouse),
        message: 'Depo başarıyla oluşturuldu',
        status: :created
      )
    else
      render_error(
        'Depo oluşturulamadı',
        errors: @warehouse.errors.full_messages
      )
    end
  end

  # PATCH/PUT /api/v1/warehouses/:id
  def update
    if @warehouse.update(warehouse_params)
      render_success(
        warehouse_data(@warehouse),
        message: 'Depo başarıyla güncellendi'
      )
    else
      render_error(
        'Depo güncellenemedi',
        errors: @warehouse.errors.full_messages
      )
    end
  end

  # DELETE /api/v1/warehouses/:id
  def destroy
    if @warehouse.items.any?
      render_error(
        'Bu depoda eşyalar bulunuyor. Önce eşyaları başka depoya taşıyın.',
        status: :unprocessable_entity
      )
    else
      @warehouse.destroy
      render_success(message: 'Depo başarıyla silindi')
    end
  end

  # GET /api/v1/warehouses/:id/qr_code
  def qr_code
    qr_path = Rails.root.join('public', 'qr_codes', 'warehouses', "#{@warehouse.qr_code}.png")

    if File.exist?(qr_path)
      send_file qr_path, type: 'image/png', disposition: 'inline'
    else
      render_error('QR kod bulunamadı', status: :not_found)
    end
  end

  # GET /api/v1/warehouses/:id/qr_code_pdf
  def qr_code_pdf
    pdf_service = QrCodePdfService.new(@warehouse)
    pdf_data = pdf_service.generate_warehouse_label

    send_data pdf_data,
              filename: "depo_#{@warehouse.name.parameterize}_qr.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  rescue => e
    Rails.logger.error "PDF generation failed: #{e.message}"
    render_error('PDF oluşturulamadı', status: :internal_server_error)
  end

  private

  def set_warehouse
    @warehouse = Warehouse.find(params[:id])
  end

  def warehouse_params
    params.require(:warehouse).permit(:name, :location, :description, :capacity, :status)
  end

  def warehouse_data(warehouse)
    {
      id: warehouse.id,
      name: warehouse.name,
      location: warehouse.location,
      description: warehouse.description,
      capacity: warehouse.capacity,
      status: warehouse.status,
      qr_code: warehouse.qr_code,
      qr_code_url: warehouse.qr_code_url,
      qr_code_pdf_url: warehouse.qr_code_pdf_url,
      statistics: warehouse.summary_stats,
      created_at: warehouse.created_at,
      updated_at: warehouse.updated_at
    }
  end

  def warehouse_detail_data(warehouse)
    base_data = warehouse_data(warehouse)
    base_data.merge(
      recent_items: warehouse.items.recent.limit(10).map { |item| basic_item_data(item) },
      recent_transactions: warehouse.recent_transactions(5).map { |transaction| basic_transaction_data(transaction) }
    )
  end

  def basic_item_data(item)
    {
      id: item.id,
      name: item.name,
      status: item.status,
      status_color: item.status_color,
      category: item.category,
      brand: item.brand
    }
  end

  def basic_transaction_data(transaction)
    {
      id: transaction.id,
      action_type: transaction.action_type,
      action_label: transaction.action_label,
      user_name: transaction.user.name,
      item_name: transaction.item.name,
      status: transaction.status,
      status_color: transaction.status_color,
      created_at: transaction.created_at
    }
  end
end
