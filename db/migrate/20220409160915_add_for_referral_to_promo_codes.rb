class AddForReferralToPromoCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_codes, :for_referral, :boolean, default: false
    add_reference :promo_codes, :user
  end
end
