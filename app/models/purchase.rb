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
#  discount   :decimal(10, 2)   default(0.0), not null
#
# Indexes
#
#  index_purchases_on_product_id  (product_id)
#  index_purchases_on_user_id     (user_id)
#

class Purchase < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :user, optional: true

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :credits, :name, presence: true

  delegate :email, :phone_number, to: :user, prefix: true
  delegate :name, to: :product, prefix: true
end