module Providers
  class ChatProvider
    def chat(messages:, model:, stream: false, &block)
      raise NotImplementedError
    end

    def models
      raise NotImplementedError
    end
  end
end
