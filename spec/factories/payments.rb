# == Schema Information
#
# Table name: payments
#
#  id            :integer          not null, primary key
#  product_id    :integer
#  user_id       :integer
#  amount        :decimal(10, 2)   not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  description   :string           not null
#  discount      :decimal(10, 2)   default(0.0)
#  last_4        :string
#  stripe_id     :string
#  status        :integer          default("success")
#  error_message :string
#  cc_cash       :decimal(10, 2)   default(0.0)
#
# Indexes
#
#  index_payments_on_product_id  (product_id)
#  index_payments_on_user_id     (user_id)
#

FactoryBot.define do
  factory :payment do
    product
    user
    amount { Faker::Number.decimal(2) }
    description { Faker::Lorem.word }
  end
end
