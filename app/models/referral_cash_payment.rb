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
class ReferralCashPayment < ApplicationRecord
  enum status: {
    pending: 0,
    ignored: 1,
    paid: 2
  }

  belongs_to :referral, class_name: 'User'
  belongs_to :referred, class_name: 'User'
  belongs_to :user_promo_code

  scope :addressed, -> { not_pending }
end
