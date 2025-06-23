# frozen_string_literal: true

class Api::V1::ItemsController < Api::V1::BaseController
  before_action :set_item, only: [:show, :update, :destroy, :checkout, :checkin, :qr_code, :qr_code_pdf]
  before_action :require_admin_for_crud!, only: [:create, :update, :destroy]

  # GET /api/v1/items
  def index
    @items = Item.includes(:warehouse, :transactions)
                 .order(updated_at: :desc)

    # Apply filters
    @items = @items.by_status(params[:status]) if params[:status].present?
    @items = @items.by_category(params[:category]) if params[:category].present?
    @items = @items.by_warehouse(params[:warehouse_id]) if params[:warehouse_id].present?

    # Search functionality
    if params[:search].present?
      @items = @items.search_items(params[:search])
    end

    # Filter by brand
    if params[:brand].present?
      @items = @items.by_brand(params[:brand])
    end

    render_paginated_collection(@items, method: :item_data)
  end

  # GET /api/v1/items/:id
  def show
    render_success(item_detail_data(@item))
  end

  # POST /api/v1/items
  def create
    @item = Item.new(item_params)

    if @item.save
      render_success(
        item_data(@item),
        message: 'Eşya başarıyla oluşturuldu',
        status: :created
      )
    else
      render_error(
        'Eşya oluşturulamadı',
        errors: @item.errors.full_messages
      )
    end
  end

  # PATCH/PUT /api/v1/items/:id
  def update
    if @item.update(item_params)
      render_success(
        item_data(@item),
        message: 'Eşya başarıyla güncellendi'
      )
    else
      render_error(
        'Eşya güncellenemedi',
        errors: @item.errors.full_messages
      )
    end
  end

  # DELETE /api/v1/items/:id
  def destroy
    if @item.active_transactions.any?
      render_error(
        'Bu eşya aktif işlemde. Önce işlemi tamamlayın.',
        status: :unprocessable_entity
      )
    else
      @item.destroy
      render_success(message: 'Eşya başarıyla silindi')
    end
  end

  # POST /api/v1/items/:id/checkout
  def checkout
    result = @item.checkout!(
      user: current_user,
      destination: checkout_params[:destination],
      return_date: checkout_params[:return_date],
      notes: checkout_params[:notes]
    )

    if result.success?
      render_success(
        item_data(@item.reload),
        message: 'Eşya başarıyla çıkış yapıldı'
      )
    else
      render_error(result.error_message)
    end
  end

  # POST /api/v1/items/:id/checkin
  def checkin
    result = @item.checkin!(
      user: current_user,
      notes: checkin_params[:notes],
      condition: checkin_params[:condition]
    )

    if result.success?
      render_success(
        item_data(@item.reload),
        message: 'Eşya başarıyla giriş yapıldı'
      )
    else
      render_error(result.error_message)
    end
  end

  # GET /api/v1/items/:id/qr_code
  def qr_code
    qr_path = Rails.root.join('public', 'qr_codes', 'items', "#{@item.qr_code}.png")

    if File.exist?(qr_path)
      send_file qr_path, type: 'image/png', disposition: 'inline'
    else
      render_error('QR kod bulunamadı', status: :not_found)
    end
  end

  # GET /api/v1/items/:id/qr_code_pdf
  def qr_code_pdf
    pdf_service = QrCodePdfService.new(@item)
    pdf_data = pdf_service.generate_item_label

    send_data pdf_data,
              filename: "esya_#{@item.name.parameterize}_qr.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  rescue => e
    Rails.logger.error "PDF generation failed: #{e.message}"
    render_error('PDF oluşturulamadı', status: :internal_server_error)
  end

  # GET /api/v1/items/categories
  def categories
    categories = Item.distinct.pluck(:category).compact.sort
    render_success(categories)
  end

  # GET /api/v1/items/brands
  def brands
    brands = Item.distinct.pluck(:brand).compact.sort
    render_success(brands)
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :serial_number, :category,
                                 :warehouse_id, :brand, :model, :value, :status)
  end

  def checkout_params
    params.require(:checkout).permit(:destination, :return_date, :notes)
  end

  def checkin_params
    params.require(:checkin).permit(:notes, :condition)
  end

  def require_admin_for_crud!
    return if current_user.can_manage_items?

    render_error('Bu işlem için yetkiniz yok', status: :forbidden)
  end

  def item_data(item)
    {
      id: item.id,
      name: item.name,
      description: item.description,
      serial_number: item.serial_number,
      category: item.category,
      brand: item.brand,
      model: item.model,
      value: item.value,
      status: item.status,
      status_label: item.status_label,
      status_color: item.status_color,
      qr_code: item.qr_code,
      qr_code_url: item.qr_code_url,
      qr_code_pdf_url: item.qr_code_pdf_url,
      warehouse: item.warehouse ? {
        id: item.warehouse.id,
        name: item.warehouse.name,
        location: item.warehouse.location
      } : nil,
      current_location: item.current_location_info,
      created_at: item.created_at,
      updated_at: item.updated_at
    }
  end

  def item_detail_data(item)
    base_data = item_data(item)
    base_data.merge(
      transaction_history: item.transactions.recent.limit(10).map { |t| transaction_summary(t) },
      statistics: {
        total_checkouts: item.transactions.checkout.count,
        total_checkins: item.transactions.checkin.count,
        days_out: item.days_checked_out,
        overdue_count: item.overdue_transactions_count
      }
    )
  end

  def transaction_summary(transaction)
    {
      id: transaction.id,
      action_type: transaction.action_type,
      action_label: transaction.action_label,
      user_name: transaction.user.name,
      destination: transaction.destination,
      return_date: transaction.return_date,
      status: transaction.status,
      status_color: transaction.status_color,
      created_at: transaction.created_at,
      completed_at: transaction.completed_at
    }
  end
end
