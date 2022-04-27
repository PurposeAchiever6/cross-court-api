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
#  promo_code_id        :integer
#  payment_method_id    :integer
#
# Indexes
#
#  index_subscriptions_on_payment_method_id  (payment_method_id)
#  index_subscriptions_on_product_id         (product_id)
#  index_subscriptions_on_promo_code_id      (promo_code_id)
#  index_subscriptions_on_status             (status)
#  index_subscriptions_on_stripe_id          (stripe_id)
#  index_subscriptions_on_user_id            (user_id)
#

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :product, -> { with_deleted }, inverse_of: :subscriptions
  belongs_to :promo_code, optional: true
  belongs_to :payment_method, optional: true
  has_many :subscription_pauses, dependent: :destroy

  has_one :last_unpaused_subscription_pause,
          -> { unpaused.order(created_at: :desc) },
          class_name: 'SubscriptionPause',
          inverse_of: :subscription

  delegate :credits, :name, :unlimited?, to: :product, prefix: false

  enum status: {
    trialing: 'trialing',
    active: 'active',
    past_due: 'past_due',
    canceled: 'canceled',
    paused: 'paused'
  }

  validates :stripe_id, presence: true

  scope :recent, -> { order('current_period_end DESC NULLS LAST') }
  scope :cancel_at_period_end, -> { where(cancel_at_period_end: true) }
  scope :period_end_on_date, ->(date) { where(current_period_end: date.all_day) }

  def assign_stripe_attrs(stripe_subscription)
    canceled_at =
      stripe_subscription.canceled_at ? Time.zone.at(stripe_subscription.canceled_at) : nil

    assign_attributes(
      stripe_id: stripe_subscription.id,
      stripe_item_id: stripe_subscription.items.data.first.id,
      status: stripe_subscription.pause_collection.nil? ? stripe_subscription.status : 'paused',
      current_period_start: Time.zone.at(stripe_subscription.current_period_start),
      current_period_end: Time.zone.at(stripe_subscription.current_period_end),
      cancel_at: stripe_subscription.cancel_at ? Time.zone.at(stripe_subscription.cancel_at) : nil,
      canceled_at: canceled_at,
      cancel_at_period_end: stripe_subscription.cancel_at_period_end
    )

    self
  end

  def can_pause?
    subscription_pauses.this_year.count < ENV['SUBSCRIPTION_PAUSES_PER_YEAR'].to_i
  end
end
