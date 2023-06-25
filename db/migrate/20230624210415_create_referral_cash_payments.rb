class CreateReferralCashPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :referral_cash_payments do |t|
      t.belongs_to :referral
      t.belongs_to :referred
      t.belongs_to :user_promo_code

      t.integer :status
      t.integer :amount

      t.timestamps

      t.index :status
    end
  end
end
