Rails.application.config.after_initialize do
  Rack::Attack.cache.store = $redis
end

# Throttle login attempts per phone number
Rack::Attack.throttle('logins per phone', limit: 10, period: 600) do |req|
  path = req.path.sub(/\.(\w+)\z/, '') # remove extension
  next unless req.post? && path.in?(%w(/api/v0/login /api/v1/login /sessions))
  phone = req.params['phone'].gsub(/\D+/, '') rescue nil  # strip non-numeric chars
  phone
end

# Throttle login attempts per ip
Rack::Attack.throttle('logins per ip', limit: 10, period: 600) do |req|
  path = req.path.sub(/\.(\w+)\z/, '') # remove extension
  next unless req.post? && path.in?(%w(/api/v0/login /api/v1/login /sessions))
  req.ip
end
