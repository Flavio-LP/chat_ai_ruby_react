FactoryBot.define do
  factory :system_prompt do
    association :user
    name { Faker::Lorem.words(number: 2).join(" ") }
    content { Faker::Lorem.paragraph }
    is_default { false }
  end
end
