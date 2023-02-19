class AddCostCreditsToSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :sessions, :cost_credits, :integer, default: 1
  end
end
