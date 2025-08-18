class NavigationComponent < ViewComponent::Base
  def initialize(current_user: nil, current_tenant: nil)
    @current_user = current_user
    @current_tenant = current_tenant
  end

  private

  def logged_in?
    @current_user.present?
  end
end
