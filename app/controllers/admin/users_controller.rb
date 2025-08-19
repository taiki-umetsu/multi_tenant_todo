class Admin::UsersController < ApplicationController
  before_action :require_admin!

  def index
    # RLS + 明示的なwhere句で二重の安全策
    @users = User.where(tenant_id: current_tenant.id).order(:created_at)
  end
end
