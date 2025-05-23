FactoryBot.define do
  factory :user do
  end
  # Creating custom dummy data for each model
  factory :event_conference do
    sequence(:name) { |n| "Event#{n}" }
    description { "This is a test" }
    location { "Test location" }
    start_time { 1.day.from_now }
    end_time { 2.days.from_now }
  end
  factory :comment do
    content { "Test comment" }
    association :user
    association :event
  end

  factory :favourite do
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
