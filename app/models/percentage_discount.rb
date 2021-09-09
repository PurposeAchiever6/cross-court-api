# == Schema Information
#
# Table name: promo_codes
#
#  id                   :integer          not null, primary key
#  discount             :integer          default(0), not null
#  code                 :string           not null
#  type                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  expiration_date      :date
#  product_id           :integer
#  stripe_promo_code_id :string
#  stripe_coupon_id     :string
#  duration             :string
#  duration_in_months   :integer
#
# Indexes
#
#  index_promo_codes_on_code        (code) UNIQUE
#  index_promo_codes_on_product_id  (product_id)
#

class PercentageDiscount < PromoCode
  def apply_discount(amount)
    (amount * (100 - discount) / 100).round(2)
  end

  def discount_amount(price)
    (price * discount / 100).round(2)
  end
end
