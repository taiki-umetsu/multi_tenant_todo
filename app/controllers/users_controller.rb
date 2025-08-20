class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]
  before_action :logout_user, only: [ :new, :create ]
  before_action :find_invitation, only: [ :new, :create ]
  before_action :validate_invitation, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    begin
      @user = User.create_with_tenant!(
        @invitation.tenant_id,
        email: @invitation.email,
        role: @invitation.role,
        password: user_params[:password],
        password_confirmation: user_params[:password_confirmation]
      )

      # 招待を削除（RLSで削除できるようにテナントIDを設定）
      User.with_tenant(@invitation.tenant_id) do
        @invitation.destroy!
      end

      # ユーザーをログインさせる
      login_user(@user)

      redirect_to root_path, notice: "アカウントが作成されました。ログインしています。"
    rescue ActiveRecord::RecordInvalid
      redirect_to new_user_path(token: params[:token]), alert: "ユーザー作成に失敗しました。再度お試しください。"
    end
  end

  private

  def find_invitation
    token = params[:token]
    @invitation = UserInvitation.find_by_token!(token)
    # RLSでテナントが参照できないので、サインアップフェーズで明示的に取得
    @invitation.tenant = Tenant.with_signup_phase { Tenant.find(@invitation.tenant_id) }
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "\u7121\u52B9\u306A\u62DB\u5F85URL\u3067\u3059\u3002"
  end

  def validate_invitation
    if @invitation.expired?
      @invitation.destroy
      redirect_to root_path, alert: "\u62DB\u5F85URL\u306E\u6709\u52B9\u671F\u9650\u304C\u5207\u308C\u3066\u3044\u307E\u3059\u3002"
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
