# == Schema Information
#
# Table name: store_items
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  price       :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class StoreItem < ApplicationRecord
  validates :name, :description, :price, presence: true
  validates :price, numericality: { greater_than: 0 }

  scope :sorted, -> { order(name: :asc) }
end
