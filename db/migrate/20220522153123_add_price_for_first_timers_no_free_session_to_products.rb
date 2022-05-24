class AddPriceForFirstTimersNoFreeSessionToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :price_for_first_timers_no_free_session, :decimal, precision: 10, scale: 2
  end
end
