class Admin::UsersController < ApplicationController
  before_action :require_admin!

  INVITATIONS_PER_PAGE = 10

  def index
    @users = User.where(tenant_id: current_tenant.id).order(:created_at)
    @invitations = UserInvitation.where(tenant_id: current_tenant.id)
                                 .order(created_at: :desc)
                                 .page(params[:page])
                                 .per(INVITATIONS_PER_PAGE)
  end
end
