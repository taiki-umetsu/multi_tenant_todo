FactoryBot.define do
  factory :user do
    tenant
    email { Faker::Internet.email }
    password { "password123" }
    role { :member }

    # RLSポリシーのためテナントコンテキストでユーザーを作成
    to_create do |user, evaluator|
      created = User.create_with_tenant!(user.tenant_id, {
        email:    user.email,
        password: user.password,
        role:     user.role
      })
      user.id = created.id
    end

    trait :admin do
      role { :admin }
    end
  end
end
