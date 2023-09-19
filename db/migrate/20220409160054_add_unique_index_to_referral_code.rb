class AddUniqueIndexToReferralCode < ActiveRecord::Migration[6.0]
  def change
    remove_index :users, :referral_code
    add_index :users, :referral_code, unique: true
  end
end
