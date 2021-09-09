class AddJerseyRentalToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :jersey_rental, :boolean, default: false
    add_column :user_sessions, :jersey_rental_payment_intent_id, :string
    add_column :user_sessions, :assigned_team, :string
  end
end
