class AddDurationAndDurationInMonthsToPromoCode < ActiveRecord::Migration[6.0]
  def change
    add_column :promo_codes, :duration, :string
    add_column :promo_codes, :duration_in_months, :integer
  end
end
