class AddPriceForMembersToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :price_for_members, :decimal, precision: 10, scale: 2
  end
end
