# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # CSRF protection
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  # API requests use token authentication instead of CSRF
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  # Authentication
  before_action :authenticate_user!, unless: -> { request.path.start_with?('/health') }
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Error handling
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  # Health check endpoint
  def health
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: '1.0.0',
      environment: Rails.env
    }
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def current_user_admin?
    user_signed_in? && current_user.admin?
  end

  def require_admin!
    unless current_user_admin?
      if request.format.json?
        render json: { error: 'Yönetici yetkisi gerekli' }, status: :forbidden
      else
        redirect_to root_path, alert: 'Bu sayfaya erişim yetkiniz yok.'
      end
    end
  end

  def api_request?
    request.path.start_with?('/api/')
  end

  private

  def handle_unauthorized(exception)
    if api_request?
      render json: {
        error: 'Yetkisiz erişim',
        message: exception.message
      }, status: :forbidden
    else
      redirect_to root_path, alert: 'Bu işlem için yetkiniz yok.'
    end
  end

  def handle_not_found(exception)
    if api_request?
      render json: {
        error: 'Kayıt bulunamadı',
        message: exception.message
      }, status: :not_found
    else
      redirect_to root_path, alert: 'Aradığınız kayıt bulunamadı.'
    end
  end

  def handle_parameter_missing(exception)
    if api_request?
      render json: {
        error: 'Eksik parametre',
        message: exception.message
      }, status: :bad_request
    else
      redirect_back(fallback_location: root_path, alert: 'Gerekli bilgiler eksik.')
    end
  end

  def json_response(data, status: :ok, message: nil)
    response = {}
    response[:message] = message if message
    response[:data] = data if data

    render json: response, status: status
  end

  def json_error(message, status: :unprocessable_entity, errors: nil)
    response = { error: message }
    response[:errors] = errors if errors

    render json: response, status: status
  end
end
