module Services
  class SyncLlmModels
    def initialize
      @provider = Providers::AbacusProvider.new
    end

    def call
      response = @provider.models
      models_data = response["data"] || []

      models_data.each do |model_data|
        LlmModel.find_or_initialize_by(provider_id: model_data["id"]).tap do |model|
          model.name = model_data["id"]
          model.display_name = model_data["id"]
          model.active = true
          model.save!
        end
      end
    end
  end
end
