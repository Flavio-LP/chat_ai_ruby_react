FactoryBot.define do
  factory :llm_model do
    sequence(:provider_id) { |n| "gpt-4o-#{n}" }
    name { provider_id }
    display_name { "GPT-4o" }
    input_price_per_million_tokens { 2.5 }
    output_price_per_million_tokens { 10.0 }
    context_window { 128_000 }
    active { true }
  end
end
