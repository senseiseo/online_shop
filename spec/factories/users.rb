FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "staff#{n}@example.com" }
    password { "password123" }
    role { :admin }

    trait :editor do
      role { :editor }
    end

    trait :manager do
      role { :manager }
    end
  end
end
