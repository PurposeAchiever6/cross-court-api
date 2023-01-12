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

FactoryBot.define do
  factory :session_allowed_product do
    session
    product
  end
end
