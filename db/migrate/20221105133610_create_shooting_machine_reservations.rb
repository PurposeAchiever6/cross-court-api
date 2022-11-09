class CreateShootingMachineReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :shooting_machine_reservations do |t|
      t.belongs_to :shooting_machine
      t.belongs_to :user_session
      t.integer :status, default: 0
      t.string :charge_payment_intent_id
      t.timestamps
    end
  end
end
