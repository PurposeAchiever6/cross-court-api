# == Schema Information
#
# Table name: referral_cash_payments
#
#  id                 :bigint           not null, primary key
#  referral_id        :bigint
#  referred_id        :bigint
#  user_promo_code_id :bigint
#  status             :integer
#  amount             :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_referral_cash_payments_on_referral_id         (referral_id)
#  index_referral_cash_payments_on_referred_id         (referred_id)
#  index_referral_cash_payments_on_status              (status)
#  index_referral_cash_payments_on_user_promo_code_id  (user_promo_code_id)
#

FactoryBot.define do
  factory :referral_cash_payment do
    user_promo_code
    referral { create(:user) }
    referred { create(:user) }
    status { :pending }
  end
end
