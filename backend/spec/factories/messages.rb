FactoryBot.define do
  factory :message do
    association :conversation
    role { "user" }
    content { Faker::Lorem.paragraph }
    status { "completed" }
  end

  trait :assistant do
    role { "assistant" }
  end

  trait :pending do
    status { "pending" }
    content { "" }
  end
end
