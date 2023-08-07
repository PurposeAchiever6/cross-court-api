class AddAllowAutoEnableGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :sessions, :allow_auto_enable_guests, :boolean, default: false
  end
end
