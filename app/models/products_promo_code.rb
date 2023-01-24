# == Schema Information
#
# Table name: products_promo_codes
#
#  id            :bigint           not null, primary key
#  product_id    :bigint
#  promo_code_id :bigint
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
