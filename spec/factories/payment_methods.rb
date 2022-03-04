# == Schema Information
#
# Table name: payment_methods
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  stripe_id  :string
#  brand      :string
#  exp_month  :integer
#  exp_year   :integer
#  last_4     :string
#  default    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payment_methods_on_user_id  (user_id)
#

FactoryBot.define do
  factory :payment_method do
    user
    stripe_id { 'stripe-payment-method-id' }
    brand { 'visa' }
    exp_month { rand(1..12) }
    exp_year { rand(10.years).seconds.from_now.year }
    last_4 { rand(0..9999) }
    default { false }
  end
end
