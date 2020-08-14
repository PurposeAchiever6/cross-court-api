class ChangeDirectionToAddress < ActiveRecord::Migration[6.0]
  def change
    rename_column :locations, :direction, :address
  end
end
