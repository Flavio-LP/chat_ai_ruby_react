class ConversationSerializer
  include Alba::Resource

  attributes :id, :title, :system_prompt_content, :summary,
             :total_input_tokens, :total_output_tokens, :total_cost_usd,
             :created_at, :updated_at

  attribute :model_id do |conv|
    conv.llm_model_id
  end

  attribute :message_count do |conv|
    conv.messages.size
  end
end
