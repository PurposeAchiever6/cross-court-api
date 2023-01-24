class AddReferralCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :referral_code, :string, unique: true
    add_index :users, :referral_code
    add_column :user_sessions, :referral_id, :bigint
    add_index :user_sessions, :referral_id

    User.where(referral_code: nil).each do |user|
      loop do
        code = SecureRandom.hex(8)
        user.update_columns(referral_code: code) and break unless User.exists?(referral_code: code)
      end
    end
  end
end
