# == Schema Information
#
# Table name: products
#
#  id             :integer          not null, primary key
#  stripe_id      :string           not null
#  credits        :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name           :string           default(""), not null
#  stripe_plan_id :string
#
# Indexes
#
#  index_products_on_stripe_id  (stripe_id) UNIQUE
#

FactoryBot.define do
  factory :product do
    stripe_id      { Faker::Lorem.word }
    credits        { Faker::Number.number(1) }
    stripe_plan_id { Faker::Lorem.word }
  end
end
