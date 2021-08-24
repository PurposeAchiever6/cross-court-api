class AddProductToPromoCode < ActiveRecord::Migration[6.0]
  def change
    add_reference :promo_codes, :product, null: true, foreign_key: true
    add_column :promo_codes, :stripe_promo_code_id, :string
    add_column :promo_codes, :stripe_coupon_id, :string
    change_column_null :promo_codes, :expiration_date, true
  end
end
