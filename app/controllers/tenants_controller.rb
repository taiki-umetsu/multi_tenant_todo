class TenantsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :require_no_login!

  def new
    @form = TenantSignupForm.new
  end

  def create
    @form = TenantSignupForm.new(form_params)

    if @form.save
      redirect_to new_tenant_path, notice: "テナント「#{@form.tenant.name}」と管理ユーザーを作成しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def form_params
    params.require(:tenant_signup_form).permit(
      :tenant_name, :user_email, :user_password, :user_password_confirmation
    )
  end
end
