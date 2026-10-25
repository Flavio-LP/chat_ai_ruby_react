class MessageSerializer
  include Alba::Resource

  attributes :id, :role, :content, :status,
             :llm_model_provider_id, :input_tokens, :output_tokens, :cost_usd,
             :created_at
end
