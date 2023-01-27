class AddInformationColumnsToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :highlighted, :boolean, default: false
    add_column :products, :highlights, :boolean, default: false
    add_column :products, :free_jersey_rental, :boolean, default: false
    add_column :products, :free_towel_rental, :boolean, default: false
    add_column :products, :description, :text
    add_column :products, :waitlist_priority, :string
  end
end
