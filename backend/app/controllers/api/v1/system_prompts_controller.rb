module Api
  module V1
    class SystemPromptsController < ApplicationController
      before_action :set_prompt, only: %i[show update destroy]

      def index
        prompts = current_user.system_prompts.order(:name)
        render json: { system_prompts: SystemPromptSerializer.new(prompts).as_json }
      end

      def show
        render json: { system_prompt: SystemPromptSerializer.new(@prompt).as_json }
      end

      def create
        prompt = current_user.system_prompts.create!(prompt_params)
        render json: { system_prompt: SystemPromptSerializer.new(prompt).as_json }, status: :created
      end

      def update
        @prompt.update!(prompt_params)
        render json: { system_prompt: SystemPromptSerializer.new(@prompt).as_json }
      end

      def destroy
        @prompt.destroy!
        head :no_content
      end

      private

      def set_prompt
        @prompt = current_user.system_prompts.find(params[:id])
      end

      def prompt_params
        params.require(:system_prompt).permit(:name, :content, :is_default)
      end
    end
  end
end
