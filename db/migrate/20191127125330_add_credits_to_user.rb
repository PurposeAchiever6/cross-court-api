class AddCreditsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :credits, :integer, null: false, default: 0
  end
end
