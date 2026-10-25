if defined?(Bullet) && Rails.env.development?
  Bullet.enable = true
  Bullet.alert = true
  Bullet.rails_logger = true
  Bullet.add_footer = false
end
