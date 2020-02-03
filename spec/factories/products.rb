# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  stripe_id    :string           not null
#  credits      :integer          default(0), not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  price        :decimal(10, 2)   default(0.0), not null
#  order_number :integer          default(0), not null
#
# Indexes
#
#  index_products_on_stripe_id  (stripe_id)
#

FactoryBot.define do
  factory :product do
    sequence :stripe_id do |n|
      "#{Faker::Lorem.unique}_#{n}"
    end
    name         { Faker::Lorem.word }
    credits      { Faker::Number.between(1, 10) }
    order_number { Faker::Number.number(1) }
    price        { Faker::Commerce.price }
  end
end
