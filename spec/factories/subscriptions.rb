# == Schema Information
#
# Table name: subscriptions
#
#  id                   :integer          not null, primary key
#  stripe_id            :string
#  stripe_item_id       :string
#  status               :string
#  cancel_at_period_end :boolean          default(FALSE)
#  current_period_start :datetime
#  current_period_end   :datetime
#  cancel_at            :datetime
#  canceled_at          :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#  product_id           :integer
#
# Indexes
#
#  index_subscriptions_on_product_id  (product_id)
#  index_subscriptions_on_status      (status)
#  index_subscriptions_on_stripe_id   (stripe_id)
#  index_subscriptions_on_user_id     (user_id)
#

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
