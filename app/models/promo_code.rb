# == Schema Information
#
# Table name: promo_codes
#
#  id                      :integer          not null, primary key
#  discount                :integer          default(0), not null
#  code                    :string           not null
#  type                    :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  expiration_date         :date
#  stripe_promo_code_id    :string
#  stripe_coupon_id        :string
#  duration                :string
#  duration_in_months      :integer
#  max_redemptions         :integer
#  max_redemptions_by_user :integer
#  times_used              :integer          default(0)
#  for_referral            :boolean          default(FALSE)
#  user_id                 :integer
#
# Indexes
#
#  index_promo_codes_on_code     (code) UNIQUE
#  index_promo_codes_on_user_id  (user_id)
#

class PromoCode < ApplicationRecord
  TYPES = %w[SpecificAmountDiscount PercentageDiscount].freeze

  has_many :user_promo_codes, dependent: :destroy

  has_many :products_promo_codes, dependent: :destroy
  has_many :products, through: :products_promo_codes

  validates :discount, :code, :type, presence: true
  validates :code, uniqueness: true
  validates :max_redemptions, numericality: { only_integer: true,
                                              greater_than: 0,
                                              allow_nil: true }
  validates :max_redemptions_by_user, numericality: { only_integer: true,
                                                      greater_than: 0,
                                                      allow_nil: true }
  validates :duration, presence: true, if: -> { products.any?(&:recurring?) }
  validates :duration_in_months, presence: true, if: -> { duration == 'repeating' }
  validates :discount,
            inclusion: { in: 1..100, message: 'needs to be between 1 and 100' },
            if: -> { type == PercentageDiscount.to_s }
  validates :products, presence: true

  enum duration: {
    forever: 'forever',
    repeating: 'repeating'
  }

  belongs_to :user, optional: true

  scope :generals, -> { where(for_referral: false) }
  scope :for_referrals, -> { where(for_referral: true) }

  def still_valid?(user, product)
    for_product?(product) && !expired? && !max_times_used? && !max_times_used_by_user?(user)
  end

  def invalid?(user, product)
    !still_valid?(user, product)
  end

  def expired?
    expiration_date ? Time.current.to_date >= expiration_date : false
  end

  def max_times_used?
    return false if max_redemptions.nil?

    times_used >= max_redemptions
  end

  def max_times_used_by_user?(user)
    return false if max_redemptions_by_user.nil?

    user_promo_code_times_used = user_promo_codes.find_by(user: user)&.times_used || 0

    user_promo_code_times_used >= max_redemptions_by_user
  end

  def for_product?(product)
    products.any? { |current_product| current_product == product }
  end
end
