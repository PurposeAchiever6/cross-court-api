SendSonar.configure do |config|
  config.env = ENV['SONAR_ENV'].to_sym
  config.token = ENV['SONAR_TOKEN']
  config.publishable_key = ENV['SONAR_PUBLISHABLE_KEY']
end
