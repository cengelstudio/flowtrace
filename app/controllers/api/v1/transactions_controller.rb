# frozen_string_literal: true

class Api::V1::TransactionsController < Api::V1::BaseController
  before_action :set_transaction, only: [:show, :update, :complete, :cancel]

  # GET /api/v1/transactions
  def index
    @transactions = Transaction.includes(:user, :item, item: :warehouse)
                              .order(created_at: :desc)

    # Apply filters
    @transactions = @transactions.by_status(params[:status]) if params[:status].present?
    @transactions = @transactions.by_action_type(params[:action_type]) if params[:action_type].present?
    @transactions = @transactions.by_user(params[:user_id]) if params[:user_id].present?
    @transactions = @transactions.by_item(params[:item_id]) if params[:item_id].present?

    # Date range filters
    if params[:start_date].present?
      @transactions = @transactions.where('created_at >= ?', Date.parse(params[:start_date]))
    end

    if params[:end_date].present?
      @transactions = @transactions.where('created_at <= ?', Date.parse(params[:end_date]).end_of_day)
    end

    # Overdue filter
    if params[:overdue] == 'true'
      @transactions = @transactions.overdue
    end

    render_paginated_collection(@transactions, method: :transaction_data)
  end

  # GET /api/v1/transactions/:id
  def show
    render_success(transaction_detail_data(@transaction))
  end

  # POST /api/v1/transactions
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user

    if @transaction.save
      render_success(
        transaction_data(@transaction),
        message: 'İşlem başarıyla oluşturuldu',
        status: :created
      )
    else
      render_error(
        'İşlem oluşturulamadı',
        errors: @transaction.errors.full_messages
      )
    end
  end

  # PATCH/PUT /api/v1/transactions/:id
  def update
    if can_modify_transaction?(@transaction)
      if @transaction.update(transaction_update_params)
        render_success(
          transaction_data(@transaction),
          message: 'İşlem başarıyla güncellendi'
        )
      else
        render_error(
          'İşlem güncellenemedi',
          errors: @transaction.errors.full_messages
        )
      end
    else
      render_error('Bu işlemi değiştirme yetkiniz yok', status: :forbidden)
    end
  end

  # POST /api/v1/transactions/:id/complete
  def complete
    if can_complete_transaction?(@transaction)
      result = @transaction.complete!(current_user)

      if result.success?
        render_success(
          transaction_data(@transaction.reload),
          message: 'İşlem başarıyla tamamlandı'
        )
      else
        render_error(result.error_message)
      end
    else
      render_error('Bu işlemi tamamlama yetkiniz yok', status: :forbidden)
    end
  end

  # POST /api/v1/transactions/:id/cancel
  def cancel
    if can_cancel_transaction?(@transaction)
      result = @transaction.cancel!(current_user, cancel_params[:reason])

      if result.success?
        render_success(
          transaction_data(@transaction.reload),
          message: 'İşlem başarıyla iptal edildi'
        )
      else
        render_error(result.error_message)
      end
    else
      render_error('Bu işlemi iptal etme yetkiniz yok', status: :forbidden)
    end
  end

  # GET /api/v1/transactions/overdue
  def overdue
    @overdue_transactions = Transaction.overdue
                                      .includes(:user, :item, item: :warehouse)
                                      .order(:return_date)

    render_collection(@overdue_transactions.map { |t| overdue_transaction_data(t) })
  end

  # GET /api/v1/transactions/statistics
  def statistics
    authorize_admin!

    stats = {
      total_transactions: Transaction.count,
      active_checkouts: Transaction.active_checkouts.count,
      overdue_items: Transaction.overdue.count,
      completed_today: Transaction.completed_today.count,
      monthly_stats: monthly_transaction_stats,
      top_users: top_users_stats,
      category_breakdown: category_breakdown_stats
    }

    render_success(stats)
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:item_id, :action_type, :destination,
                                       :return_date, :notes)
  end

  def transaction_update_params
    params.require(:transaction).permit(:destination, :return_date, :notes)
  end

  def cancel_params
    params.require(:cancel).permit(:reason)
  end

  def can_modify_transaction?(transaction)
    current_user.admin? || transaction.user == current_user
  end

  def can_complete_transaction?(transaction)
    return true if current_user.admin?
    return true if transaction.user == current_user
    return true if transaction.action_type == 'checkin' # Anyone can help with checkins

    false
  end

  def can_cancel_transaction?(transaction)
    current_user.admin? || transaction.user == current_user
  end

  def authorize_admin!
    render_error('Bu işlem için admin yetkisi gerekli', status: :forbidden) unless current_user.admin?
  end

  def transaction_data(transaction)
    {
      id: transaction.id,
      action_type: transaction.action_type,
      destination: transaction.destination,
      return_date: transaction.return_date,
      notes: transaction.notes,
      status: transaction.status,
      user: {
        id: transaction.user.id,
        name: transaction.user.name,
        email: transaction.user.email
      },
      item: {
        id: transaction.item.id,
        name: transaction.item.name,
        category: transaction.item.category,
        warehouse_name: transaction.item.warehouse&.name
      },
      created_at: transaction.created_at,
      updated_at: transaction.updated_at
    }
  end

  def transaction_detail_data(transaction)
    base_data = transaction_data(transaction)
    base_data.merge(
      item_details: {
        id: transaction.item.id,
        name: transaction.item.name,
        description: transaction.item.description,
        serial_number: transaction.item.serial_number,
        category: transaction.item.category,
        brand: transaction.item.brand,
        model: transaction.item.model
      }
    )
  end

  def overdue_transaction_data(transaction)
    transaction_data(transaction).merge(
      overdue_info: {
        days_overdue: transaction.days_overdue,
        expected_return: transaction.return_date,
        urgency_level: transaction.urgency_level
      }
    )
  end

  def monthly_transaction_stats
    # Last 6 months stats
    6.times.map do |i|
      date = i.months.ago
      month_start = date.beginning_of_month
      month_end = date.end_of_month

      {
        month: date.strftime('%Y-%m'),
        month_name: I18n.l(date, format: '%B %Y'),
        checkouts: Transaction.checkout.where(created_at: month_start..month_end).count,
        checkins: Transaction.checkin.where(created_at: month_start..month_end).count
      }
    end.reverse
  end

  def top_users_stats
    Transaction.joins(:user)
              .group('users.name')
              .count
              .sort_by { |_, count| -count }
              .first(10)
              .map { |name, count| { name: name, transaction_count: count } }
  end

  def category_breakdown_stats
    Transaction.joins(item: :warehouse)
              .joins(:item)
              .group('items.category')
              .count
              .map { |category, count| { category: category, count: count } }
  end
end
