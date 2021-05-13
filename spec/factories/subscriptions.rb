FactoryBot.define do
  factory :subscription do
    user
    product
    stripe_id { 'stripe-subscription-id' }
    status { 'active' }
    current_period_start { Time.current }
    current_period_end { Time.current + 1.month }
    cancel_at_period_end { false }
    cancel_at { nil }
    canceled_at { nil }
  end
end
