# == Schema Information
#
# Table name: promo_codes
#
#  id         :integer          not null, primary key
#  discount   :integer          default(0), not null
#  code       :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_promo_codes_on_code  (code) UNIQUE
#

class PromoCode < ApplicationRecord
  TYPES = %w[SpecificAmountDiscount PercentageDiscount].freeze

  validates :discount, :code, presence: true
  validates :code, uniqueness: true
end
