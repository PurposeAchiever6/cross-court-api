# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  stripe_id   :string           not null
#  credits     :integer          default(0), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  price       :decimal(10, 2)   default(0.0), not null
#  description :text
#
# Indexes
#
#  index_products_on_stripe_id  (stripe_id)
#

class Product < ApplicationRecord
  has_many :purchases, dependent: :nullify

  validates :credits, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stripe_id, presence: true, uniqueness: true
end
