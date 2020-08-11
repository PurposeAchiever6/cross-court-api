class AddZipcodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :zipcode, :string
  end
end
