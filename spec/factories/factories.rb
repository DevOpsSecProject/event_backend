FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
  end

  factory :comment do
    content { "Test comment" }
    association :user
    association :event
  end

  factory :favorite do
    association :user
    association :event
  end

  factory :ticket do
    price { 100.0 }
    sequence(:seat_number) { |n| "A#{n}" }
    association :user
    association :event
  end
end
