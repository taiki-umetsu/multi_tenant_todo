FactoryBot.define do
  factory :tenant do
    name { Faker::Company.name }

    trait :with_specific_name do
      name { "Acme Corp" }
    end
  end
end
