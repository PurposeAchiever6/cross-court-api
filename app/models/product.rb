# == Schema Information
#
# Table name: products
#
#  id                                     :integer          not null, primary key
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
#  skill_session_credits                  :integer          default(0)
#  max_rollover_credits                   :integer
#  season_pass                            :boolean          default(FALSE)
#
# Indexes
#
#  index_products_on_deleted_at    (deleted_at)
#  index_products_on_product_type  (product_type)
#

class Product < ApplicationRecord
  UNLIMITED = -1

  acts_as_paranoid

  enum product_type: { one_time: 0, recurring: 1 }
  enum available_for: { everyone: 0, reserve_team: 1 }

  has_one_attached :image
  has_many :payments, dependent: :nullify

  has_many :subscriptions
  has_many :products_promo_codes, dependent: :destroy
  has_many :promo_codes, through: :products_promo_codes

  validates :name, :credits, :order_number, presence: true
  validates :skill_session_credits, presence: true, if: -> { recurring? }

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

  def self.for_user(user)
    user&.reserve_team ? Product.reserve_team.or(Product.one_time) : Product.everyone
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
