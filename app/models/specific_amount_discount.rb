# == Schema Information
#
# Table name: promo_codes
#
#  id              :integer          not null, primary key
#  discount        :integer          default(0), not null
#  code            :string           not null
#  type            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  expiration_date :date             not null
#
# Indexes
#
#  index_promo_codes_on_code  (code) UNIQUE
#

class SpecificAmountDiscount < PromoCode
  def apply_discount(amount)
    discount < amount ? amount - discount : 0
  end

  def discount_amount(_)
    discount
  end
end
