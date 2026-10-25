Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount ActionCable.server => "/cable"

  devise_for :users,
    path: "api/v1/auth",
    path_names: { sign_in: "sign_in", sign_out: "sign_out", registration: "sign_up" },
    controllers: {
      sessions: "api/v1/auth/sessions",
      registrations: "api/v1/auth/registrations"
    }

  namespace :api do
    namespace :v1 do
      resources :conversations, only: %i[index show create update destroy] do
        resources :messages, only: %i[index create]
      end

      resources :system_prompts, only: %i[index show create update destroy]
      resources :llm_models, only: %i[index show]
      resources :documents, only: %i[index show create destroy]
    end
  end

  require "yabeda/prometheus"
  mount Yabeda::Prometheus::Exporter => "/metrics"

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development?
end
