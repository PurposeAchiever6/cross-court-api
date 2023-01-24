class AddFreePausesPerYearToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :free_pauses_per_year, :integer, default: 0
  end
end
