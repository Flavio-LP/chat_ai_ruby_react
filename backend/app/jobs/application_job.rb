class ApplicationJob < ActiveJob::Base
  queue_as :default

  discard_on ActiveJob::DeserializationError

  retry_on Faraday::TimeoutError, wait: :polynomially_longer, attempts: 3
end
