FactoryBot.define do
  factory :user_invitation do
    association :tenant
    email { Faker::Internet.email }
    role { :member }
    token { SecureRandom.urlsafe_base64(32) }
    expires_at { 1.day.from_now }

    # RLSポリシーのためテナントコンテキストで招待を作成
    to_create do |invitation, evaluator|
      User.with_tenant(invitation.tenant_id) do
        invitation.save!
      end
    end

    trait :admin do
      role { :admin }
    end

    trait :expired do
      expires_at { 1.hour.ago }
    end

    trait :expiring_soon do
      expires_at { 10.minutes.from_now }
    end
  end
end
