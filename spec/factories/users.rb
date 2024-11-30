FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    username { Faker::Internet.unique.username(specifier: 5..20) }
    password { 'password123' }
    password_confirmation { 'password123' }
    status { :active }
    confirmed_at { Time.current }

    trait :with_wallet do
      after(:build) do |user|
        user.generate_wallet_and_keys
      end
    end

    trait :with_2fa do
      two_factor_enabled { true }
      two_factor_secret { ROTP::Base32.random }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :inactive do
      status { :inactive }
    end

    trait :suspended do
      status { :suspended }
    end
  end
end 