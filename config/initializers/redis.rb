$redis = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379'),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)
