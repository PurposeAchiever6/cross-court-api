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

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :product, with_deleted: true

  delegate :credits, :name, to: :product, prefix: false

  enum status: {
    trialing: 'trialing',
    active: 'active',
    past_due: 'past_due',
    canceled: 'canceled'
  }

  validates :stripe_id, presence: true

  scope :recent, -> { order('current_period_end DESC NULLS LAST') }

  def assign_stripe_attrs(stripe_subscription)
    assign_attributes(
      stripe_id: stripe_subscription.id,
      stripe_item_id: stripe_subscription.items.data.first.id,
      status: stripe_subscription.status,
      current_period_start: Time.zone.at(stripe_subscription.current_period_start),
      current_period_end: Time.zone.at(stripe_subscription.current_period_end),
      cancel_at: stripe_subscription.cancel_at ? Time.zone.at(stripe_subscription.cancel_at) : nil,
      canceled_at: stripe_subscription.canceled_at ? Time.zone.at(stripe_subscription.canceled_at) : nil,
      cancel_at_period_end: stripe_subscription.cancel_at_period_end
    )

    self
  end
end
