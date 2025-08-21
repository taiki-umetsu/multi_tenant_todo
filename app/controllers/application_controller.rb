class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_variant
  around_action :with_tenant_transaction

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

  def login_user(user)
    session[:user_id] = user.id
    session[:tenant_id] = user.tenant_id
  end

  def logout_user
    session[:user_id] = nil
    session[:tenant_id] = nil
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "管理者権限が必要です"
  end

  def with_tenant_transaction
    return yield unless current_user && current_tenant

    ActiveRecord::Base.transaction do
      conn = ActiveRecord::Base.connection
      quoted = conn.quote(current_tenant.id)
      conn.execute("SET LOCAL app.current_tenant = #{quoted}")
      yield
    end
  end

  helper_method :current_user, :current_tenant, :logged_in?
end
