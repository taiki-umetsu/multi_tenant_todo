class TenantSignupForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :tenant_name, :string
  attribute :user_email, :string
  attribute :user_password, :string
  attribute :user_password_confirmation, :string

  validates :tenant_name, presence: true
  validates :user_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :user_password, presence: true, length: { minimum: 6 }
  validates :user_password_confirmation, presence: true
  validate :password_confirmation_matches

  def save
    return false unless valid?

    Tenant.with_signup_phase do
      create_tenant!
      create_admin_user!
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    handle_record_errors(e.record)
    false
  end

  def tenant
    @tenant
  end

  def user
    @user
  end

  private

  def create_tenant!
    @tenant = Tenant.create!(name: tenant_name)
  end

  def create_admin_user!
    @user = User.create_with_tenant!(@tenant.id, {
      email: user_email,
      password: user_password,
      role: :admin
    })
  end

  def password_confirmation_matches
    return unless user_password.present? && user_password_confirmation.present?
    return if user_password == user_password_confirmation

    errors.add(:user_password_confirmation, "パスワードが一致しません")
  end

  def handle_record_errors(record)
    case record
    when Tenant
      errors.add(:tenant_name, record.errors.full_messages.join(", "))
    when User
      record.errors.each do |error|
        case error.attribute
        when :email
          errors.add(:user_email, error.message)
        when :password
          errors.add(:user_password, error.message)
        else
          field_name = "user_#{error.attribute}"
          errors.add(field_name, error.message)
        end
      end
    end
  end
end
