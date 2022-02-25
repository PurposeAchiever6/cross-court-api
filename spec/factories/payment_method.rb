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
