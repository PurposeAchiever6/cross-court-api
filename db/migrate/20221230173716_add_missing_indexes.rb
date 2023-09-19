class AddMissingIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :phone_number, unique: true
    add_index :user_promo_codes, %i[promo_code_id user_id], unique: true
  end
end
