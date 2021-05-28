# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  credits         :integer          default(0), not null
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  price           :decimal(10, 2)   default(0.0), not null
#  order_number    :integer          default(0), not null
#  product_type    :integer          default("one_time")
#  stripe_price_id :string
#  label           :string
#

class Product < ApplicationRecord
  enum product_type: { one_time: 0, recurring: 1 }

  has_one_attached :image
  has_many :purchases, dependent: :nullify

  validates :credits, :order_number, presence: true
end
