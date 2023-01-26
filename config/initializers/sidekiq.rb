Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379'),
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }

  config.on(:startup) do
    schedule_file = 'config/schedule.yml'

    if File.exist?(schedule_file) && Sidekiq.server?
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
      url: ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379'),
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end
