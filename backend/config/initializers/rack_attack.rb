Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
  url: ENV.fetch("REDIS_URL", "redis://redis:6379/0")
)

Rack::Attack.throttle("auth/ip", limit: 5, period: 60) do |req|
  req.ip if req.path.start_with?("/api/v1/auth/sign_in")
end

Rack::Attack.throttle("api/ip", limit: 120, period: 60) do |req|
  req.ip if req.path.start_with?("/api/")
end

Rack::Attack.throttle("api/user", limit: 120, period: 60) do |req|
  if req.path.start_with?("/api/")
    token = req.env["HTTP_AUTHORIZATION"]&.sub(/^Bearer /, "")
    token if token.present?
  end
end
