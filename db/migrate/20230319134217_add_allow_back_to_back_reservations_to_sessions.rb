class AddAllowBackToBackReservationsToSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :sessions, :allow_back_to_back_reservations, :boolean, default: true
  end
end
