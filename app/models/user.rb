class User < ApplicationRecord
  belongs_to :tenant
  # 決定論的暗号化でemailの検索とuniqueインデックスを維持
  encrypts :email, deterministic: true
  has_secure_password
  enum :role, { member: 0, admin: 1 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { scope: :tenant_id }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :role, presence: true

  class << self
    def with_tenant(tenant_id, &block)
      transaction do
        connection.execute("SET LOCAL app.current_tenant = '#{tenant_id}'")
        yield
      end
    end

    def create_with_tenant!(tenant_id, attributes)
      with_tenant(tenant_id) do
        create!(tenant_id: tenant_id, **attributes)
      end
    end
  end
end
