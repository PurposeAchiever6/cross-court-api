# == Schema Information
#
# Table name: purchases
#
#  id         :integer          not null, primary key
#  product_id :integer
#  user_id    :integer
#  price      :decimal(10, 2)   not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  credits    :integer          not null
#  name       :string           not null
#
# Indexes
#
#  index_purchases_on_product_id  (product_id)
#  index_purchases_on_user_id     (user_id)
#

FactoryBot.define do
  factory :purchase do
    product
    user
    price   { Faker::Number.decimal(2) }
    credits { Faker::Number.number(1) }
    name    { Faker::Lorem.word }
  end
end
