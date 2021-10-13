# == Schema Information
#
# Table name: products_promo_codes
#
#  id            :integer          not null, primary key
#  product_id    :integer
#  promo_code_id :integer
#
# Indexes
#
#  index_products_promo_codes_on_product_id     (product_id)
#  index_products_promo_codes_on_promo_code_id  (promo_code_id)
#

class ProductsPromoCode < ApplicationRecord
  belongs_to :product
  belongs_to :promo_code
end
