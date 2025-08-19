class NavigationComponentPreview < ViewComponent::Preview
  def admin_logged_in
    current_tenant = FactoryBot.build(:tenant, name: "テストテナント")
    current_user = FactoryBot.build(:user, :admin, email: "admin@example.com", tenant: current_tenant)

    render NavigationComponent.new(
      current_user: current_user,
      current_tenant: current_tenant
    )
  end

  def member_logged_in
    current_tenant = FactoryBot.build(:tenant, name: "テストテナント")
    current_user = FactoryBot.build(:user, email: "member@example.com", role: :member, tenant: current_tenant)

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
