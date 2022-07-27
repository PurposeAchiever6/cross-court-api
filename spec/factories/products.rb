# == Schema Information
#
# Table name: products
#
#  id                                     :integer          not null, primary key
#  credits                                :integer          default(0), not null
#  name                                   :string           not null
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  price                                  :decimal(10, 2)   default(0.0), not null
#  order_number                           :integer          default(0), not null
#  product_type                           :integer          default("one_time")
#  stripe_price_id                        :string
#  label                                  :string
#  deleted_at                             :datetime
#  price_for_members                      :decimal(10, 2)
#  stripe_product_id                      :string
#  referral_cc_cash                       :decimal(, )      default(0.0)
#  price_for_first_timers_no_free_session :decimal(10, 2)
#  available_for                          :integer          default("everyone")
#  skill_session_credits                  :integer          default(0)
#
# Indexes
#
#  index_products_on_deleted_at    (deleted_at)
#  index_products_on_product_type  (product_type)
#

FactoryBot.define do
  factory :product do
    sequence :stripe_price_id do |n|
      "#{Faker::Lorem.unique}_#{n}"
    end
    name { Faker::Lorem.word }
    credits { Faker::Number.between(1, 10) }
    skill_session_credits { Faker::Number.between(1, 10) }
    order_number { Faker::Number.number(1) }
    price { Faker::Commerce.price }
    referral_cc_cash { 0 }
    available_for { 'everyone' }
    product_type { 'one_time' }
  end

  trait :unlimited do
    credits { Product::UNLIMITED }
    product_type { 'recurring' }
  end
end
