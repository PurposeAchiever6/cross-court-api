# == Schema Information
#
# Table name: promo_codes
#
#  id         :integer          not null, primary key
#  discount   :integer          default(0), not null
#  code       :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
