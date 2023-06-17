class UpdateNoBookingChargeForProducts < ActiveRecord::Migration[7.0]
  def change
    rename_column :products,
                  :no_booking_charge_after_cancellation_window,
                  :no_booking_charge_feature

    add_column :products, :no_booking_charge_feature_hours, :integer, default: 3
  end
end
