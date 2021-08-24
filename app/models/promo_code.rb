# == Schema Information
#
# Table name: promo_codes
#
#  id                   :integer          not null, primary key
#  discount             :integer          default(0), not null
#  code                 :string           not null
#  type                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  expiration_date      :date
#  product_id           :integer
#  stripe_promo_code_id :string
#  stripe_coupon_id     :string
#
# Indexes
#
#  index_promo_codes_on_code        (code) UNIQUE
#  index_promo_codes_on_product_id  (product_id)
#

class PromoCode < ApplicationRecord
  TYPES = %w[SpecificAmountDiscount PercentageDiscount].freeze

  has_many :user_promo_codes, dependent: :destroy
  belongs_to :product

  validates :discount, :code, :type, presence: true
  validates :code, uniqueness: true
  validates :discount,
            inclusion: { in: 1..100, message: 'needs to be between 1 and 100' },
            if: -> { type == PercentageDiscount.to_s }

  def still_valid?(user)
    user_promo_codes.where(user: user).none? && Time.current.to_date <= expiration_date
  end
end
