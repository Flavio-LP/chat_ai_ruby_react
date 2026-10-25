FactoryBot.define do
  factory :conversation do
    association :user
    title { Faker::Lorem.sentence(word_count: 3) }
    system_prompt_content { nil }
  end
end
