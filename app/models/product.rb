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

class Product < ApplicationRecord
  validates :stripe_id, :credits, presence: true
  validates :credits, numericality: { greater_than_or_equal_to: 0 }
  validates :stripe_id, uniqueness: true
end
