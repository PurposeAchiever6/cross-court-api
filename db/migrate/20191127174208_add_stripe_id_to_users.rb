class AddStripeIdToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.references :product, index: true

      t.string :stripe_id, index: true
    end
  end
end
