Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.ignore_actions = ["RailsHealthController#show"]

  config.lograge.custom_options = lambda do |event|
    extras = {
      host: event.payload[:host],
      remote_ip: event.payload[:remote_ip],
      user_id: event.payload[:user_id]
    }
    extras[:conversation_id] = event.payload[:conversation_id] if event.payload[:conversation_id]
    extras[:model] = event.payload[:model] if event.payload[:model]
    extras
  end
end
