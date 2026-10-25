class SyncLlmModelsJob < ApplicationJob
  queue_as :maintenance

  def perform
    Services::SyncLlmModels.new.call
  end
end
