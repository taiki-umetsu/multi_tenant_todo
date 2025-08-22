class Admin::UserInvitationsController < ApplicationController
  before_action :require_admin!

  def create
    @invitation = UserInvitation.new(invitation_params)
    @invitation.tenant = current_tenant

    if @invitation.save
      # 招待成功時は1ページ目の招待データを取得
      @invitations = UserInvitation.where(tenant_id: current_tenant.id)
                                   .order(created_at: :desc)
                                   .page(1)
                                   .per(Admin::UsersController::INVITATIONS_PER_PAGE)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_users_path, notice: "招待URLを作成しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_users_path, alert: "招待の作成に失敗しました" }
      end
    end
  end

  private

  def invitation_params
    params.require(:user_invitation).permit(:email).merge(
      role: safe_role(params[:user_invitation][:role])
    )
  end

  def safe_role(role)
    UserInvitation.roles.key?(role) ? role : "member"
  end
end
