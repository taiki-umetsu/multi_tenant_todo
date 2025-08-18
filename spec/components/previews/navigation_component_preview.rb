class NavigationComponentPreview < ViewComponent::Preview
  def logged_in
    current_tenant = FactoryBot.build(:tenant, name: "テストテナント")
    current_user = FactoryBot.build(:user, email: "test@example.com", tenant: current_tenant)

    render NavigationComponent.new(
      current_user: current_user,
      current_tenant: current_tenant
    )
  end

  def logged_out
    render NavigationComponent.new(
      current_user: nil,
      current_tenant: nil
    )
  end
end
