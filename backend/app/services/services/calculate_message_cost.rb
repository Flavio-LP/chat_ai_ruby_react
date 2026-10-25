module Services
  class CalculateMessageCost
    def initialize(model_provider_id, input_tokens, output_tokens)
      @model_provider_id = model_provider_id
      @input_tokens = input_tokens.to_i
      @output_tokens = output_tokens.to_i
    end

    def call
      model = LlmModel.find_by(provider_id: @model_provider_id)
      return 0 unless model

      input_cost = (@input_tokens / 1_000_000.0) * model.input_price_per_million_tokens.to_f
      output_cost = (@output_tokens / 1_000_000.0) * model.output_price_per_million_tokens.to_f

      (input_cost + output_cost).round(10)
    end
  end
end
