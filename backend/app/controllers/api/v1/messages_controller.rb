module Api
  module V1
    class MessagesController < ApplicationController
      before_action :set_conversation

      def index
        pagy, messages = pagy(@conversation.messages.order(:created_at))
        render json: {
          messages: MessageSerializer.new(messages).as_json,
          pagination: pagy_metadata(pagy)
        }
      end

      def create
        message = @conversation.messages.create!(
          role: "user",
          content: message_params[:content],
          status: "completed"
        )

        assistant_message = @conversation.messages.create!(
          role: "assistant",
          content: "",
          status: "pending"
        )

        GenerateReplyJob.perform_later(@conversation.id, assistant_message.id)

        render json: {
          user_message: MessageSerializer.new(message).as_json,
          assistant_message: MessageSerializer.new(assistant_message).as_json
        }, status: :created
      end

      private

      def set_conversation
        @conversation = current_user.conversations.find(params[:conversation_id])
      end

      def message_params
        params.require(:message).permit(:content)
      end
    end
  end
end
