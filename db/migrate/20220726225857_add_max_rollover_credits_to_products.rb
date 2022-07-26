class AddMaxRolloverCreditsToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :max_rollover_credits, :integer
  end
end
