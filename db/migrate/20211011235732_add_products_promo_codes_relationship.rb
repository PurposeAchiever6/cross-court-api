class AddProductsPromoCodesRelationship < ActiveRecord::Migration[6.0]
  def change
    create_table :products_promo_codes do |t|
      t.references :product
      t.references :promo_code
    end
  end
end
