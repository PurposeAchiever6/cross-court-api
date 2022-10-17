class AddGuestsAllowedToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :guests_allowed, :integer
    add_column :sessions, :guests_allowed_per_user, :integer
  end
end
