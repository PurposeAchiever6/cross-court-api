class ChangePaymentsDiscount < ActiveRecord::Migration[6.0]
  def up
    change_column :payments, :discount, :decimal, precision: 10, scale: 2, default: 0, null: true
  end

  def down
    change_column :payments, :discount, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
