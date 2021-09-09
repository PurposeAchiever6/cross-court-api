class AddReferralCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :referral_code, :string, unique: true, index: true
    add_column :user_sessions, :referral_id, :bigint, index: true

    User.where(referral_code: nil).each do |user|
      loop do
        code = SecureRandom.hex(8)
        user.update_columns(referral_code: code) and break unless User.where(referral_code: code).exists?
      end
    end
  end
end
