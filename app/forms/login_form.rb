class LoginForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :password, :string
  attribute :tenant_name, :string

  validates :email, presence: true, email: true
  validates :password, presence: true
  validates :tenant_name, presence: true

  def authenticate
    return nil unless valid?

    tenant = Tenant.with_signup_phase do
      Tenant.find_by(name: tenant_name)
    end
    return nil unless tenant

    user = User.with_tenant(tenant.id) do
      User.find_by(email: email)
    end
    return nil unless user&.authenticate(password)

    user
  end
end
