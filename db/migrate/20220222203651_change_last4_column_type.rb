class ChangeLast4ColumnType < ActiveRecord::Migration[6.0]
  def change
    change_column(:payment_methods, :last_4, :string)
  end
end
