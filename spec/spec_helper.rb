# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'factory_bot_rails'
require 'helpers'
require 'webmock/rspec'
require 'shoulda/matchers'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

FactoryBot.factories.clear
FactoryBot.reload

Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.include Helpers
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = 'random'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include FactoryBot::Syntax::Methods

  config.before :each do
    Sidekiq::Worker.clear_all

    ENV['STRIPE_PUBLISHABLE_KEY'] = 'stripe-publishable-key'

    allow(SonarService).to receive(:add_update_customer)
    allow(Stripe::Coupon).to receive(:create).and_return(double(id: 'coupon-id'))
    allow(Stripe::PromotionCode).to receive(:create).and_return(double(id: 'promo-id'))

    ActionMailer::Base.deliveries.clear
  end
end
