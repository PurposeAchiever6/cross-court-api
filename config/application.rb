require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'active_storage/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.load_defaults 7.0
    config.active_job.queue_adapter = :sidekiq

    config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', nil)

    config.autoload_paths += %W[#{config.root}/lib]
    config.eager_load_paths << Rails.root.join('extras')
    config.action_controller.raise_on_open_redirects = false

    ActionMailer::Base.smtp_settings = {
      address: 'smtp.sendgrid.net',
      port: 25,
      domain: ENV.fetch('SERVER_URL', nil),
      authentication: :plain,
      user_name: ENV.fetch('SENDGRID_USERNAME', nil),
      password: ENV.fetch('SENDGRID_PASSWORD', nil)
    }
    config.action_mailer.default_url_options = { host: ENV.fetch('SERVER_URL', nil) }
    config.action_mailer.default_options = {
      from: 'Crosscourt <no-reply@cross-court.com>'
    }

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.to_prepare do
      Devise::Mailer.layout 'mailer'
    end
  end
end
