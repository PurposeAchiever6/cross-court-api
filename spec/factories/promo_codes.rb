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
#  for_referral                 :boolean          default(FALSE)
#  user_id                      :bigint
#  user_max_checked_in_sessions :integer
#
# Indexes
#
#  index_promo_codes_on_code     (code) UNIQUE
#  index_promo_codes_on_user_id  (user_id)
#

FactoryBot.define do
  factory :promo_code, class: SpecificAmountDiscount do
    discount { Faker::Number.number(digits: 2) }
    code { Faker::Lorem.word }
    expiration_date { 1.year.from_now }
    duration { 'repeating' }
    duration_in_months { rand(1..10) }
    max_redemptions { nil }
    max_redemptions_by_user { nil }
    user_max_checked_in_sessions { nil }
    times_used { 0 }
    for_referral { false }
    user { nil }
    products { [create(:product)] }
  end
end
