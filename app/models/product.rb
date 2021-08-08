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
#  deleted_at      :datetime
#
# Indexes
#
#  index_products_on_deleted_at  (deleted_at)
#

class Product < ApplicationRecord
  UNLIMITED = -1

  acts_as_paranoid

  enum product_type: { one_time: 0, recurring: 1 }

  has_one_attached :image
  has_many :purchases, dependent: :nullify

  validates :credits, :order_number, presence: true

  def unlimited?
    credits == UNLIMITED
  end

  def memberships_count
    Subscription.joins(:user).where(product_id: id, status: :active).count
  end
end
