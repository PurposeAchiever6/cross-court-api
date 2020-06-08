class AddExpirationDateToPromoCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_codes, :expiration_date, :date, null: false
  end
end
