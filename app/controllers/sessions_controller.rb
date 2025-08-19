class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]
  before_action :require_no_login!, only: [ :new, :create ]
  def new
    @form = LoginForm.new
  end

  def create
    @form = LoginForm.new(login_params)

    if (user = @form.authenticate)
      login_user(user)
      redirect_to root_path, notice: "ログインしました"
    else
      flash.now[:alert] = "テナント名、メールアドレス、またはパスワードが正しくありません"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    logout_user
    redirect_to login_path, notice: "ログアウトしました"
  end

  private

  def login_params
    params.require(:login_form).permit(:tenant_name, :email, :password)
  end
end
