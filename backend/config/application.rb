require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true

    config.active_job.queue_adapter = :sidekiq

    config.active_record.query_log_tags_enabled = true
    config.active_record.query_log_tags = [:application, :controller, :action, :job]

    config.time_zone = "UTC"
    config.i18n.default_locale = "pt-BR"
    config.i18n.available_locales = %w[pt-BR en]

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch("FRONTEND_URL", "http://localhost:5173")
        resource "/api/*",
          headers: :any,
          methods: %i[get post put patch delete options head],
          expose: %w[Authorization]
        resource "/cable",
          headers: :any,
          methods: %i[get post]
      end
    end

    config.middleware.use Rack::Attack
  end
end
