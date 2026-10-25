module Services
  class BuildConversationContext
    RECENT_MESSAGES_LIMIT = 20

    def initialize(conversation)
      @conversation = conversation
    end

    def call
      messages = []

      if @conversation.system_prompt_content.present?
        messages << { role: "system", content: @conversation.system_prompt_content }
      end

      if @conversation.summary.present?
        messages << { role: "system", content: "Resumo da conversa até agora: #{@conversation.summary}" }
      end

      recent = @conversation.messages.for_context(RECENT_MESSAGES_LIMIT)
      messages + recent.map { |m| { role: m.role, content: m.content } }
    end
  end
end
