# frozen_string_literal: true

class Api::V1::AuthenticationController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:login]

  # POST /api/v1/auth/login
  def login
    user = User.find_by(email: login_params[:email])

    if user&.valid_password?(login_params[:password])
      sign_in(user)
      render_success(
        user_data(user),
        message: 'Başarıyla giriş yapıldı'
      )
    else
      render_error('Geçersiz email veya şifre', status: :unauthorized)
    end
  end

  # POST /api/v1/auth/logout
  def logout
    if user_signed_in?
      sign_out(current_user)
      render_success(message: 'Başarıyla çıkış yapıldı')
    else
      render_error('Zaten çıkış yapılmış', status: :unauthorized)
    end
  end

  # GET /api/v1/auth/me
  def me
    if user_signed_in?
      render_success(user_data(current_user))
    else
      render_error('Kimlik doğrulaması gerekli', status: :unauthorized)
    end
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end

  def user_data(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      display_name: user.display_name,
      permissions: {
        can_manage_users: user.can_manage_users?,
        can_view_reports: user.can_view_reports?,
        can_manage_warehouses: user.can_manage_warehouses?,
        can_manage_items: user.can_manage_items?,
        can_scan_qr_codes: user.can_scan_qr_codes?
      },
      statistics: {
        total_transactions: user.total_transactions_count,
        active_checkouts: user.active_checkouts.count,
        overdue_checkouts: user.overdue_checkouts.count
      }
    }
  end
end
