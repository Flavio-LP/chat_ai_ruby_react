class LlmModelSerializer
  include Alba::Resource

  attributes :id, :provider_id, :name, :display_name,
             :input_price_per_million_tokens, :output_price_per_million_tokens,
             :context_window, :active
end
