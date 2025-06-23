# frozen_string_literal: true

class Api::V1::SearchController < Api::V1::BaseController

  # GET /api/v1/search
  def index
    query = params[:q]&.strip

    if query.blank?
      render_error('Arama terimi gerekli', status: :unprocessable_entity)
      return
    end

    if query.length < 2
      render_error('Arama terimi en az 2 karakter olmalı', status: :unprocessable_entity)
      return
    end

    results = perform_search(query)

    render_success({
      query: query,
      total_results: results.values.sum { |items| items.size },
      results: results
    })
  end

  # GET /api/v1/search/suggestions
  def suggestions
    query = params[:q]&.strip

    if query.blank? || query.length < 2
      render_success([])
      return
    end

    suggestions = generate_suggestions(query)
    render_success(suggestions)
  end

  # GET /api/v1/search/qr/:code
  def qr_lookup
    qr_code = params[:code]&.strip&.upcase

    if qr_code.blank?
      render_error('QR kod gerekli', status: :unprocessable_entity)
      return
    end

    result = lookup_by_qr_code(qr_code)

    if result
      render_success(result)
    else
      render_error('QR kod bulunamadı', status: :not_found)
    end
  end

  # GET /api/v1/search/filters
  def filters
    filters = {
      categories: Item.distinct.pluck(:category).compact.sort,
      brands: Item.distinct.pluck(:brand).compact.sort,
      warehouses: Warehouse.active_warehouses.pluck(:id, :name).map { |id, name| { id: id, name: name } },
      statuses: {
        items: Item.statuses.keys.map { |status| { value: status, label: I18n.t("item.status.#{status}") } },
        transactions: Transaction.statuses.keys.map { |status| { value: status, label: I18n.t("transaction.status.#{status}") } }
      },
      action_types: Transaction.action_types.keys.map { |type| { value: type, label: I18n.t("transaction.action_type.#{type}") } }
    }

    render_success(filters)
  end

  private

  def perform_search(query)
    results = {}

    # Search items
    items = Item.search_items(query)
               .includes(:warehouse, :transactions)
               .limit(20)

    results[:items] = items.map { |item| search_item_data(item) }

    # Search warehouses
    warehouses = Warehouse.search_by_name_and_location(query)
                         .includes(:items)
                         .limit(10)

    results[:warehouses] = warehouses.map { |warehouse| search_warehouse_data(warehouse) }

    # Search transactions
    transactions = Transaction.joins(:item, :user)
                             .where(
                               'items.name ILIKE ? OR users.name ILIKE ? OR transactions.destination ILIKE ?',
                               "%#{query}%", "%#{query}%", "%#{query}%"
                             )
                             .includes(:item, :user)
                             .limit(15)

    results[:transactions] = transactions.map { |transaction| search_transaction_data(transaction) }

    # Search users (admin only)
    if current_user.admin?
      users = User.where('name ILIKE ? OR email ILIKE ?', "%#{query}%", "%#{query}%")
                  .limit(10)

      results[:users] = users.map { |user| search_user_data(user) }
    end

    results
  end

  def generate_suggestions(query)
    suggestions = []

    # Item name suggestions
    item_names = Item.where('name ILIKE ?', "%#{query}%")
                    .distinct
                    .pluck(:name)
                    .first(5)

    suggestions += item_names.map { |name| { type: 'item', value: name, label: name } }

    # Category suggestions
    categories = Item.where('category ILIKE ?', "%#{query}%")
                    .distinct
                    .pluck(:category)
                    .compact
                    .first(3)

    suggestions += categories.map { |cat| { type: 'category', value: cat, label: "Kategori: #{cat}" } }

    # Brand suggestions
    brands = Item.where('brand ILIKE ?', "%#{query}%")
                .distinct
                .pluck(:brand)
                .compact
                .first(3)

    suggestions += brands.map { |brand| { type: 'brand', value: brand, label: "Marka: #{brand}" } }

    # Warehouse suggestions
    warehouse_names = Warehouse.where('name ILIKE ? OR location ILIKE ?', "%#{query}%", "%#{query}%")
                              .distinct
                              .pluck(:name)
                              .first(3)

    suggestions += warehouse_names.map { |name| { type: 'warehouse', value: name, label: "Depo: #{name}" } }

    suggestions.uniq { |s| s[:value] }.first(15)
  end

  def lookup_by_qr_code(qr_code)
    # Try to find item first
    if qr_code.start_with?('IT-')
      item = Item.find_by(qr_code: qr_code)
      return qr_item_data(item) if item
    end

    # Try to find warehouse
    if qr_code.start_with?('WH-')
      warehouse = Warehouse.find_by(qr_code: qr_code)
      return qr_warehouse_data(warehouse) if warehouse
    end

    # Try both if format is unclear
    item = Item.find_by(qr_code: qr_code)
    return qr_item_data(item) if item

    warehouse = Warehouse.find_by(qr_code: qr_code)
    return qr_warehouse_data(warehouse) if warehouse

    nil
  end

  def search_item_data(item)
    {
      id: item.id,
      type: 'item',
      name: item.name,
      description: item.description,
      category: item.category,
      brand: item.brand,
      status: item.status,
      status_label: item.status_label,
      status_color: item.status_color,
      warehouse_name: item.warehouse&.name,
      current_location: item.current_location_info,
      url: "/items/#{item.id}"
    }
  end

  def search_warehouse_data(warehouse)
    {
      id: warehouse.id,
      type: 'warehouse',
      name: warehouse.name,
      location: warehouse.location,
      description: warehouse.description,
      status: warehouse.status,
      item_count: warehouse.items.count,
      url: "/warehouses/#{warehouse.id}"
    }
  end

  def search_transaction_data(transaction)
    {
      id: transaction.id,
      type: 'transaction',
      action_type: transaction.action_type,
      action_label: transaction.action_label,
      item_name: transaction.item.name,
      user_name: transaction.user.name,
      destination: transaction.destination,
      status: transaction.status,
      status_color: transaction.status_color,
      created_at: transaction.created_at,
      url: "/transactions/#{transaction.id}"
    }
  end

  def search_user_data(user)
    {
      id: user.id,
      type: 'user',
      name: user.name,
      email: user.email,
      role: user.role,
      transaction_count: user.transactions.count,
      url: "/users/#{user.id}"
    }
  end

  def qr_item_data(item)
    {
      type: 'item',
      id: item.id,
      name: item.name,
      description: item.description,
      category: item.category,
      brand: item.brand,
      model: item.model,
      serial_number: item.serial_number,
      status: item.status,
      status_label: item.status_label,
      status_color: item.status_color,
      warehouse: item.warehouse ? {
        id: item.warehouse.id,
        name: item.warehouse.name,
        location: item.warehouse.location
      } : nil,
      current_location: item.current_location_info,
      can_checkout: item.available_for_checkout?,
      can_checkin: item.checked_out?,
      actions: available_item_actions(item)
    }
  end

  def qr_warehouse_data(warehouse)
    {
      type: 'warehouse',
      id: warehouse.id,
      name: warehouse.name,
      location: warehouse.location,
      description: warehouse.description,
      status: warehouse.status,
      capacity: warehouse.capacity,
      current_items: warehouse.items.count,
      available_space: warehouse.available_capacity,
      recent_items: warehouse.items.recent.limit(5).map { |item|
        {
          id: item.id,
          name: item.name,
          status: item.status,
          status_color: item.status_color
        }
      }
    }
  end

  def available_item_actions(item)
    actions = []

    if item.available_for_checkout?
      actions << { type: 'checkout', label: 'Çıkış Yap', icon: 'arrow-right' }
    end

    if item.checked_out?
      actions << { type: 'checkin', label: 'Giriş Yap', icon: 'arrow-left' }
    end

    if current_user.can_manage_items?
      actions << { type: 'edit', label: 'Düzenle', icon: 'edit' }
    end

    actions << { type: 'view', label: 'Detaylar', icon: 'eye' }

    actions
  end
end
