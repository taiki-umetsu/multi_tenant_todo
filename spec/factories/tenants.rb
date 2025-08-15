FactoryBot.define do
  factory :tenant do
    name { Faker::Company.name }

    # RLSポリシーのためsignup_phaseを使用してテナントを作成
    initialize_with { Tenant.with_signup_phase { Tenant.new(attributes) } }

    trait :with_specific_name do
      name { "Acme Corp" }
    end
  end
end
