class AddUserMaxCheckedInSessionsToPromoCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_codes, :user_max_checked_in_sessions, :integer
  end
end
