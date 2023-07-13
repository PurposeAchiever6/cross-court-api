class AddNoBookingChargeFeatureLabelToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :no_booking_charge_feature_priority, :string
  end
end
