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
#
# Indexes
#
#  index_promo_codes_on_code  (code) UNIQUE
#

class PercentageDiscount < PromoCode
  def apply_discount(amount)
    (amount * (100 - discount) / 100).round(2)
  end

  def discount_amount(price)
    (price * discount / 100).round(2)
  end
end
