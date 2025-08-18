class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_variant

  private

  def authenticate_user!
    return if current_user

    redirect_to login_path, alert: "ログインが必要です"
  end

  def require_no_login!
    return unless current_user

    redirect_to root_path, alert: "すでにログインしています"
  end

  def current_user
    return nil unless session[:user_id] && session[:tenant_id]

    @current_user ||= User.with_tenant(session[:tenant_id]) do
      User.find_by(id: session[:user_id])
    end
  end

  def current_tenant
    return nil unless session[:tenant_id]

    @current_tenant ||= Tenant.with_signup_phase do
      Tenant.find_by(id: session[:tenant_id])
    end
  end

  def set_variant
    request.variant = :mobile if mobile_device?
  end

  def mobile_device?
    request.user_agent =~ /Mobile|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i
  end

  def logged_in?
    current_user.present?
  end

  helper_method :current_user, :current_tenant, :logged_in?
end
