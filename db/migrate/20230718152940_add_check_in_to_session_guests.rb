class AddCheckInToSessionGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :session_guests, :checked_in, :boolean, default: :false
    add_column :session_guests, :assigned_team, :string
  end
end
