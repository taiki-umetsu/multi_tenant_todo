class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  class << self
    def with_signup_phase(&block)
      transaction do
        # [NOTE] SET LOCALの効果は、コミットのされたかどうかにかかわらず現在のトランザクションが終了するまでしか持続しません。
        # https://www.postgresql.jp/document/17/html/sql-set.html
        connection.execute("SET LOCAL app.signup_phase = '1'")
        yield
      end
    end

    def create_with_signup(attributes)
      with_signup_phase do
        create(attributes)
      end
    end
  end
end
