class AddPromoCodesIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :promo_codes, :code, unique: true
  end
end
