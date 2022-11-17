class AddSeasonPassCreditsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :credits_without_expiration, :integer, default: 0
  end
end
