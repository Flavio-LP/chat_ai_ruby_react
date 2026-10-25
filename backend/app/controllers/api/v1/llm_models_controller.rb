module Api
  module V1
    class LlmModelsController < ApplicationController
      def index
        models = LlmModel.active.order(:name)
        render json: { llm_models: LlmModelSerializer.new(models).as_json }
      end

      def show
        model = LlmModel.active.find(params[:id])
        render json: { llm_model: LlmModelSerializer.new(model).as_json }
      end
    end
  end
end
