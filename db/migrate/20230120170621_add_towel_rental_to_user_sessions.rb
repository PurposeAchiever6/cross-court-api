class AddTowelRentalToUserSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :user_sessions, :towel_rental, :boolean, default: false
    add_column :user_sessions, :towel_rental_payment_intent_id, :string
  end
end
