# == Schema Information
#
# Table name: promo_codes
#
#  id                           :bigint           not null, primary key
#  discount                     :integer          default(0), not null
#  code                         :string           not null
#  type                         :string           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  expiration_date              :date
#  stripe_promo_code_id         :string
#  stripe_coupon_id             :string
#  duration                     :string
#  duration_in_months           :integer
#  max_redemptions              :integer
#  max_redemptions_by_user      :integer
#  times_used                   :integer          default(0)
#  user_id                      :bigint
#  user_max_checked_in_sessions :integer
#  use                          :string           default("general")
#  only_for_new_members         :boolean          default(FALSE)
#
# Indexes
#
#  index_promo_codes_on_code     (code) UNIQUE
#  index_promo_codes_on_use      (use)
#  index_promo_codes_on_user_id  (user_id)
#

class PercentageDiscount < PromoCode
  def apply_discount(amount)
    (amount * (100 - discount) / 100.00).round(2)
  end

  def discount_amount(price)
    (price * discount / 100.00).round(2)
  end
end
