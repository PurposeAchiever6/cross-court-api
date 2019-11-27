class AddPlanIdToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :stripe_plan_id, :string
  end
end
