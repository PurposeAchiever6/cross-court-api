class CreateUserPromoCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :user_promo_codes do |t|
      t.references :user, null: false, index: true
      t.references :promo_code, null: false, index: true

      t.timestamps
    end
  end
end
