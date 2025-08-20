class UserInvitation < ApplicationRecord
  EXPIRES_IN = 1.day

  belongs_to :tenant

  # Userテーブルと同じ暗号化設定
  encrypts :email, deterministic: true

  # Userテーブルと同じenum設定
  enum :role, { member: 0, admin: 1 }

  validates :email, presence: true, email: true, uniqueness: { scope: :tenant_id }
  validates :role, presence: true
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :email_not_already_registered

  before_validation :generate_token, on: :create
  before_validation :set_expires_at, on: :create

  scope :valid, -> { where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  def expired?
    expires_at <= Time.current
  end

  class << self
    def with_token(token, &block)
      transaction do
        connection.execute("SET LOCAL app.invitation_token = #{connection.quote(token)}")
        yield
      end
    end

    def find_by_token!(token)
      with_token(token) do
        find_by!(token: token)
      end
    end
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expires_at
    self.expires_at ||= EXPIRES_IN.from_now
  end

  def email_not_already_registered
    return unless email.present? && tenant_id.present?

    # 同一テナント内でEmailが既にUserテーブルに存在するかチェック
    if User.where(tenant_id: tenant_id, email: email).exists?
      errors.add(:email, "は既に登録済みです")
    end
  end
end
