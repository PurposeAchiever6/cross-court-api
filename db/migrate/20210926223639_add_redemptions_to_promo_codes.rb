class AddRedemptionsToPromoCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_codes, :max_redemptions, :integer
    add_column :promo_codes, :max_redemptions_by_user, :integer
    add_column :promo_codes, :times_used, :integer, default: 0

    add_column :user_promo_codes, :times_used, :integer, default: 0
  end
end
