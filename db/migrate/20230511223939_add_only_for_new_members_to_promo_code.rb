class AddOnlyForNewMembersToPromoCode < ActiveRecord::Migration[7.0]
  def change
    add_column :promo_codes, :only_for_new_members, :boolean, default: false

    PromoCode.referral.update_all(only_for_new_members: true, user_max_checked_in_sessions: nil)
  end

  def down
    remove_column :promo_codes, :only_for_new_members

    PromoCode.referral.update_all(user_max_checked_in_sessions: 0)
  end
end
