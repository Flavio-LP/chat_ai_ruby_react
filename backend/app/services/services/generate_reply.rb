module Services
  class GenerateReply
    THROTTLE_INTERVAL = 0.1

    def initialize(conversation, message)
      @conversation = conversation
      @message = message
      @provider = Providers::AbacusProvider.new
    end

    def call
      context = BuildConversationContext.new(@conversation).call
      model_id = @conversation.llm_model&.provider_id || ENV.fetch("DEFAULT_LLM_MODEL", "gpt-4o-mini")
      buffer = ""
      last_broadcast = Time.current
      input_tokens = 0
      output_tokens = 0
      started_at = Time.current

      @provider.chat(messages: context, model: model_id, stream: true) do |chunk, _|
        delta = chunk.dig("choices", 0, "delta", "content")
        usage = chunk.dig("usage")

        if delta
          buffer += delta
          @message.update_columns(content: @message.content + delta)

          if Time.current - last_broadcast >= THROTTLE_INTERVAL
            broadcast_delta(delta)
            last_broadcast = Time.current
          end
        end

        if usage
          input_tokens = usage["prompt_tokens"].to_i
          output_tokens = usage["completion_tokens"].to_i
        end
      end

      broadcast_delta(buffer) if buffer.present?

      cost = CalculateMessageCost.new(model_id, input_tokens, output_tokens).call

      @message.update!(
        status: "completed",
        llm_model_provider_id: model_id,
        input_tokens: input_tokens,
        output_tokens: output_tokens,
        cost_usd: cost
      )

      @conversation.increment!(:total_input_tokens, input_tokens)
      @conversation.increment!(:total_output_tokens, output_tokens)
      @conversation.increment!(:total_cost_usd, cost)

      record_metrics(model_id, input_tokens, output_tokens, cost, started_at)
      broadcast_done
    end

    private

    def broadcast_delta(delta)
      ActionCable.server.broadcast(
        "conversation_#{@conversation.id}",
        { type: "delta", message_id: @message.id, delta: delta }
      )
    end

    def broadcast_done
      ActionCable.server.broadcast(
        "conversation_#{@conversation.id}",
        { type: "done", message_id: @message.id }
      )
    end

    def record_metrics(model_id, input_tokens, output_tokens, cost, started_at)
      Yabeda.llm.requests_total.increment({ model: model_id, status: "success" })
      Yabeda.llm.tokens_total.increment({ model: model_id, direction: "input" }, by: input_tokens)
      Yabeda.llm.tokens_total.increment({ model: model_id, direction: "output" }, by: output_tokens)
      Yabeda.llm.cost_usd_total.set({ model: model_id }, cost)
      Yabeda.llm.latency_seconds.measure({ model: model_id }, Time.current - started_at)
    rescue StandardError
      # metrics are non-critical
    end
  end
end
