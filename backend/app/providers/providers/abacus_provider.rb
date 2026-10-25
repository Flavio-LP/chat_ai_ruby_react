module Providers
  class AbacusProvider < ChatProvider
    def initialize
      @client = OpenAI::Client.new(
        access_token: ENV.fetch("ABACUS_API_KEY"),
        uri_base: ENV.fetch("ABACUS_API_URL", "https://apps.abacus.ai/api/v0/")
      )
    end

    def chat(messages:, model:, stream: false, &block)
      if stream && block
        @client.chat(parameters: { model: model, messages: messages, stream: block })
      else
        @client.chat(parameters: { model: model, messages: messages })
      end
    end

    def models
      @client.models.list
    end
  end
end
