SendSonar.configure do |config|
  config.env = :live
  config.token = ENV['SONAR_TOKEN']
  config.publishable_key = ENV['SONAR_PUBLISHABLE_KEY']
end
