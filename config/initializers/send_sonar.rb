SendSonar.configure do |config|
  config.env = ENV['SONAR_ENV'].to_sym
  config.token = ENV.fetch('SONAR_TOKEN', nil)
  config.publishable_key = ENV.fetch('SONAR_PUBLISHABLE_KEY', nil)
end
