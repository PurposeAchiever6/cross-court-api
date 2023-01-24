# == Schema Information
#
# Table name: subscriptions
#
#  id                           :bigint           not null, primary key
#  stripe_id                    :string
#  stripe_item_id               :string
#  status                       :string
#  cancel_at_period_end         :boolean          default(FALSE)
#  current_period_start         :datetime
#  current_period_end           :datetime
#  cancel_at                    :datetime
#  canceled_at                  :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :bigint
#  product_id                   :bigint
#  promo_code_id                :bigint
#  payment_method_id            :bigint
#  mark_cancel_at_period_end_at :date
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

  has_one :upcoming_subscription_pause,
          -> { upcoming.order(created_at: :desc) },
          class_name: 'SubscriptionPause',
          inverse_of: :subscription,
          dependent: nil

  has_one :upcoming_or_actual_subscription_pause,
          -> { upcoming_or_actual.order(created_at: :desc) },
          class_name: 'SubscriptionPause',
          inverse_of: :subscription,
          dependent: nil

  delegate :credits, :skill_session_credits, :name, :unlimited?, to: :product, prefix: false

  enum status: {
    trialing: 'trialing',
    active: 'active',
    past_due: 'past_due',
    canceled: 'canceled',
    paused: 'paused'
  }

  validates :stripe_id, presence: true

  scope :active_or_paused, -> { where(status: %i[active paused]) }
  scope :recent, -> { order('current_period_end DESC NULLS LAST') }
  scope :cancel_at_period_end, -> { where(cancel_at_period_end: true) }
  scope :not_cancel_at_period_end, -> { where(cancel_at_period_end: false) }
  scope :period_end_on_date, ->(date) { where(current_period_end: date.all_day) }
  scope :for_product, ->(product) { where(product_id: product) }

  def assign_stripe_attrs(stripe_subscription)
    canceled_at =
      stripe_subscription.canceled_at ? Time.zone.at(stripe_subscription.canceled_at) : nil

    pause_collection = stripe_subscription.pause_collection

    stripe_subscription_status = stripe_subscription.status
    is_pause = pause_collection.present? && stripe_subscription_status == 'active'
    status = is_pause ? 'paused' : stripe_subscription_status

    assign_attributes(
      stripe_id: stripe_subscription.id,
      stripe_item_id: stripe_subscription.items.data.first.id,
      status:,
      current_period_start: Time.zone.at(stripe_subscription.current_period_start),
      current_period_end: Time.zone.at(stripe_subscription.current_period_end),
      cancel_at: stripe_subscription.cancel_at ? Time.zone.at(stripe_subscription.cancel_at) : nil,
      canceled_at:,
      cancel_at_period_end: stripe_subscription.cancel_at_period_end
    )

    if subscription_pauses.actual.any?
      actual_subscription_pause = subscription_pauses.actual.last
      if pause_collection.nil? && stripe_subscription.status == 'active'
        actual_subscription_pause.update!(status: :finished)
      end
      actual_subscription_pause.update!(status: :canceled) if status == 'canceled'
    end

    self
  end

  def can_free_pause?
    subscription_pauses.finished.free.this_year.count < product.free_pauses_per_year
  end

  def will_pause?
    subscription_pauses.upcoming.any?
  end

  def no_longer_active?
    canceled? || past_due? || cancel_at_period_end?
  end

  def cancel_at_next_period_end?
    mark_cancel_at_period_end_at.present? \
      && mark_cancel_at_period_end_at >= current_period_start + 1.month \
        && mark_cancel_at_period_end_at <= current_period_end + 1.month
  end
end
