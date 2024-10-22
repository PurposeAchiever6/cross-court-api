# == Schema Information
#
# Table name: products
#
#  id                                     :bigint           not null, primary key
#  credits                                :integer          default(0), not null
#  name                                   :string           not null
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  price                                  :decimal(10, 2)   default(0.0), not null
#  order_number                           :integer          default(0), not null
#  product_type                           :integer          default("one_time")
#  stripe_price_id                        :string
#  label                                  :string
#  deleted_at                             :datetime
#  price_for_members                      :decimal(10, 2)
#  stripe_product_id                      :string
#  referral_cc_cash                       :decimal(, )      default(0.0)
#  price_for_first_timers_no_free_session :decimal(10, 2)
#  available_for                          :integer          default("everyone")
#  max_rollover_credits                   :integer
#  skill_session_credits                  :integer          default(0)
#  season_pass                            :boolean          default(FALSE)
#  scouting                               :boolean          default(FALSE)
#  free_pauses_per_year                   :integer          default(0)
#  highlighted                            :boolean          default(FALSE)
#  highlights                             :boolean          default(FALSE)
#  free_jersey_rental                     :boolean          default(FALSE)
#  free_towel_rental                      :boolean          default(FALSE)
#  description                            :text
#  waitlist_priority                      :string
#  promo_code_id                          :bigint
#  no_booking_charge_feature              :boolean          default(FALSE)
#  no_booking_charge_feature_hours        :integer          default(3)
#  no_booking_charge_feature_priority     :string
#  credits_expiration_days                :integer
#  trial                                  :boolean          default(FALSE)
#
# Indexes
#
#  index_products_on_deleted_at     (deleted_at)
#  index_products_on_product_type   (product_type)
#  index_products_on_promo_code_id  (promo_code_id)
#

class Product < ApplicationRecord
  UNLIMITED = -1

  acts_as_paranoid
  has_paper_trail

  enum product_type: { one_time: 0, recurring: 1 }
  enum available_for: { everyone: 0, reserve_team: 1 }
  enum frontend_theme: { dark: 0, white: 1, highlighted: 2 }, _suffix: true

  belongs_to :promo_code, optional: true

  has_one_attached :image
  has_many :payments, as: :chargeable, dependent: :nullify

  has_many :subscriptions
  has_many :products_promo_codes, dependent: :destroy
  has_many :promo_codes, through: :products_promo_codes
  has_many :session_allowed_products, dependent: :destroy

  validates :name,
            :credits,
            :order_number,
            :product_type,
            :available_for,
            :frontend_theme,
            presence: true
  validates :skill_session_credits, presence: true, if: -> { recurring? }
  validates :no_booking_charge_feature_hours,
            numericality: { only_integer: true,
                            greater_than: 0,
                            less_than_or_equal_to: Session::CANCELLATION_PERIOD.to_i / 3600 }

  scope :no_booking_charge_feature, -> { where(no_booking_charge_feature: true) }
  scope :trials, -> { where(trial: true) }

  def self.for_user(user)
    user&.reserve_team ? Product.reserve_team.or(Product.one_time) : Product.everyone
  end

  def unlimited?
    credits == UNLIMITED
  end

  def skill_session_unlimited?
    skill_session_credits == UNLIMITED
  end

  def memberships_count
    subscriptions.active.count
  end

  def price(user = nil)
    if apply_price_for_first_timers_no_free_session?(user)
      return price_for_first_timers_no_free_session
    end

    return price_for_members if apply_price_for_members?(user)

    super()
  end

  def update_recurring_price(new_price, update_existing_subscriptions: true)
    return if price == new_price || one_time?

    stripe_price_id = StripeService.create_price(
      name:,
      product_type:,
      price: new_price,
      stripe_product_id:
    ).id

    update!(price: new_price, stripe_price_id:)

    Products::UpdateExistingSubscriptionsPriceJob.perform_later(id) if update_existing_subscriptions
  end

  def preference_promo_code(user)
    return promo_code unless user

    last_week_purchases = user.payments.products.where('created_at >= ?', 1.week.ago)

    trial_product = Product.where(id: last_week_purchases.pluck(:chargeable_id), trial: true).last

    trial_promo_code = trial_product&.promo_code

    if user.never_been_a_member? && trial_promo_code&.still_valid?(user, self)
      return trial_promo_code
    end

    promo_code
  end

  private

  def apply_price_for_first_timers_no_free_session?(user)
    one_time? \
      && user \
        && price_for_first_timers_no_free_session \
          && !user.received_free_session? \
            && !user.reserve_any_session? \
              && !user.credits?
  end

  def apply_price_for_members?(user)
    one_time? && user && price_for_members && user.active_subscription
  end
end
