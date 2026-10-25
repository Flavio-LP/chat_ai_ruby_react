module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :set_conversation, only: %i[show update destroy]

      def index
        pagy, conversations = pagy(current_user.conversations.order(created_at: :desc))
        render json: {
          conversations: ConversationSerializer.new(conversations).as_json,
          pagination: pagy_metadata(pagy)
        }
      end

      def show
        render json: { conversation: ConversationSerializer.new(@conversation).as_json }
      end

      def create
        conversation = current_user.conversations.new(conversation_params)

        if params[:system_prompt_id].present?
          prompt = current_user.system_prompts.find(params[:system_prompt_id])
          conversation.system_prompt_content = prompt.content
        end

        conversation.save!
        render json: { conversation: ConversationSerializer.new(conversation).as_json }, status: :created
      end

      def update
        @conversation.update!(conversation_params)
        render json: { conversation: ConversationSerializer.new(@conversation).as_json }
      end

      def destroy
        @conversation.destroy!
        head :no_content
      end

      private

      def set_conversation
        @conversation = current_user.conversations.find(params[:id])
      end

      def conversation_params
        params.require(:conversation).permit(:title, :llm_model_id)
      end
    end
  end
end
