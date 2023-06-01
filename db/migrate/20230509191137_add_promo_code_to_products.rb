class AddPromoCodeToProducts < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :promo_code
  end
end
