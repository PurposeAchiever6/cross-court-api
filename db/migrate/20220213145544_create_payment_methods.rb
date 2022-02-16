class CreatePaymentMethods < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_methods do |t|
      t.references :user, null: false, index: true
      t.string :stripe_id
      t.string :brand
      t.integer :exp_month
      t.integer :exp_year
      t.integer :last_4
      t.boolean :default

      t.timestamps
    end
  end
end
