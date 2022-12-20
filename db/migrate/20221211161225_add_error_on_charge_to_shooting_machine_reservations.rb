class AddErrorOnChargeToShootingMachineReservations < ActiveRecord::Migration[6.0]
  def change
    add_column :shooting_machine_reservations, :error_on_charge, :string
  end
end
