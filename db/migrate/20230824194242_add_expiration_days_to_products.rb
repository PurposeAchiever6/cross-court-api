class AddExpirationDaysToProducts < ActiveRecord::Migration[7.0]
  def up
    add_column :products, :credits_expiration_days, :integer

    Product.one_time.where(season_pass: false).update_all(credits_expiration_days: 30)
  end

  def down
    remove_column :products, :credits_expiration_days
  end
end
