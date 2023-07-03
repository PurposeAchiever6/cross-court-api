class AddLateCancellationSettingsToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :late_cancellation_fee, :integer, default: 10
    add_column :locations, :late_cancellation_reimburse_credit, :boolean, default: false
  end
end
