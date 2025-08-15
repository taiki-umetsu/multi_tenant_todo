FactoryBot.define do
  factory :user do
    tenant
    email { Faker::Internet.email }
    password { "password123" }
    role { :member }

    trait :admin do
      role { :admin }
    end
  end
end
