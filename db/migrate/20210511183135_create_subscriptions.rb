class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_id
      t.string :stripe_item_id
      t.string :status
      t.boolean :cancel_at_period_end, default: false
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :cancel_at
      t.datetime :canceled_at
      t.timestamps

      t.belongs_to :user
      t.belongs_to :product
    end

    add_index :subscriptions, :stripe_id
    add_index :subscriptions, :status
  end
end
