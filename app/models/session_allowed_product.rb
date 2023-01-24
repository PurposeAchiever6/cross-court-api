# == Schema Information
#
# Table name: session_allowed_products
#
#  id         :bigint           not null, primary key
#  session_id :bigint
#  product_id :bigint
#
# Indexes
#
#  index_session_allowed_products_on_product_id  (product_id)
#  index_session_allowed_products_on_session_id  (session_id)
#

class SessionAllowedProduct < ApplicationRecord
  belongs_to :session
  belongs_to :product
end
