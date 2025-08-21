class Admin::UsersController < ApplicationController
  before_action :require_admin!

  def index
    @users = User.where(tenant_id: current_tenant.id).order(:created_at)
    @invitations = UserInvitation.where(tenant_id: current_tenant.id)
                                 .order(created_at: :desc)
  end
end
