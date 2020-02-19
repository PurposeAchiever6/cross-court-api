class CreatePromoCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :promo_codes do |t|
      t.integer :discount, null: false, default: 0
      t.string :code, null: false
      t.string :type, null: false

      t.timestamps
    end
  end
end
