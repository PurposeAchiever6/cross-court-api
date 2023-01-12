# == Schema Information
#
# Table name: session_allowed_products
#
#  id         :integer          not null, primary key
#  session_id :integer
#  product_id :integer
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
