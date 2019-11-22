class ChangeLocationsAttributes < ActiveRecord::Migration[6.0]
  def change
    change_table :locations, bulk: true do |t|
      t.string :city, null: false, default: ''
      t.string :zipcode, null: false, default: ''
    end

    remove_column :sessions, :name, :string, null: false, default: ''
  end
end
