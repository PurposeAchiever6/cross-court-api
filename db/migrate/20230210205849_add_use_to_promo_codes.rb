class AddUseToPromoCodes < ActiveRecord::Migration[7.0]
  def up
    add_column :promo_codes, :use, :string, default: 'general'
    add_index :promo_codes, :use

    PromoCode.where(for_referral: true).update_all(use: 'referral')
    PromoCode.where(for_referral: false).update_all(use: 'general')

    remove_column :promo_codes, :for_referral
  end

  def down
    add_column :promo_codes, :for_referral, :boolean, default: false

    PromoCode.where(use: 'referral').update_all(for_referral: true)
    PromoCode.where(use: 'general').update_all(for_referral: false)

    remove_index :promo_codes, :use
    remove_column :promo_codes, :use
  end
end
