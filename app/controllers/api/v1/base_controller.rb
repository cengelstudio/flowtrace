# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  # Skip CSRF for API requests
  skip_before_action :verify_authenticity_token

  # Set default response format
  before_action :set_default_response_format

  # Pagination
  include Pagy::Backend

  # Serialization
  include ActionController::Serialization

  protected

  def set_default_response_format
    request.format = :json
  end

  # Pagination helper
  def paginate(collection, per_page: 20)
    pagy, records = pagy(collection, items: per_page)
    {
      records: records,
      pagination: {
        current_page: pagy.page,
        total_pages: pagy.pages,
        total_count: pagy.count,
        per_page: pagy.items,
        next_page: pagy.next,
        prev_page: pagy.prev
      }
    }
  end

  # Standard JSON responses
  def render_success(data = nil, message: nil, status: :ok)
    response = { success: true }
    response[:message] = message if message
    response[:data] = data if data

    render json: response, status: status
  end

  def render_error(message, status: :unprocessable_entity, errors: nil)
    response = {
      success: false,
      error: message
    }
    response[:errors] = errors if errors

    render json: response, status: status
  end

  def render_collection(collection, serializer: nil, per_page: 20)
    paginated = paginate(collection, per_page: per_page)

    data = {
      items: paginated[:records],
      pagination: paginated[:pagination]
    }

    render_success(data)
  end

  def render_paginated_collection(collection, method: nil, per_page: 20)
    paginated = paginate(collection, per_page: per_page)

    items = if method
              paginated[:records].map { |record| send(method, record) }
            else
              paginated[:records]
            end

    data = {
      items: items,
      pagination: paginated[:pagination]
    }

    render_success(data)
  end

  def render_resource(resource, serializer: nil, message: nil)
    if resource.persisted?
      render_success(resource, message: message)
    else
      render_error('Kayıt oluşturulamadı', errors: resource.errors.full_messages)
    end
  end

  # Authorization helper using Pundit
  def authorize_resource(resource, action = nil)
    action ||= action_name.to_sym
    authorize resource, action
  rescue Pundit::NotAuthorizedError
    render_error('Bu işlem için yetkiniz yok', status: :forbidden)
  end

  # Admin authorization
  def require_admin!
    return if current_user&.admin?
    render_error('Bu işlem için admin yetkisi gerekli', status: :forbidden)
  end

  # Current user helper for API authentication
  def current_user
    @current_user ||= authenticate_user_from_token || super
  end

  private

  def authenticate_user_from_token
    # Token-based authentication for API requests
    # This could be JWT, API key, or session-based
    # For now, we'll use session-based authentication
    return nil unless user_signed_in?
    super
  end
end
