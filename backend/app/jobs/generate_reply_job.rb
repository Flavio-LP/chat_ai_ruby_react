class GenerateReplyJob < ApplicationJob
  queue_as :chat

  sidekiq_options retry: 3, dead: true

  retry_on Faraday::TimeoutError, wait: :polynomially_longer, attempts: 3

  def perform(conversation_id, message_id)
    conversation = Conversation.find(conversation_id)
    message = Message.find(message_id)

    return if message.status == "completed"

    message.update!(status: "streaming")
    broadcast_start(conversation, message)

    Services::GenerateReply.new(conversation, message).call
  rescue StandardError => e
    message&.update!(status: "failed")
    broadcast_failure(conversation, message, e.message)
    Sentry.capture_exception(e, extra: { conversation_id:, message_id: })
    raise
  end

  private

  def broadcast_start(conversation, message)
    ActionCable.server.broadcast(
      "conversation_#{conversation.id}",
      { type: "streaming_start", message_id: message.id }
    )
  end

  def broadcast_failure(conversation, message, error_message)
    return unless conversation && message

    ActionCable.server.broadcast(
      "conversation_#{conversation.id}",
      { type: "failed", message_id: message.id, error: "Falha ao gerar resposta" }
    )
  end
end
