module Providers
  class LocalEmbeddingsProvider
    MODEL_NAME = "Xenova/all-MiniLM-L6-v2".freeze
    DIMENSIONS = 384

    def initialize
      @model = Informers.pipeline("feature-extraction", MODEL_NAME)
    end

    def embed(texts)
      Array(texts).map do |text|
        @model.call(text, pooling: "mean", normalize: true).first
      end
    end

    def model_name
      MODEL_NAME
    end
  end
end
