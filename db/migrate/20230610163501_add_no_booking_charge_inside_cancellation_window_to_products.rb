class AddNoBookingChargeInsideCancellationWindowToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :no_booking_charge_after_cancellation_window, :boolean, default: false
  end
end
