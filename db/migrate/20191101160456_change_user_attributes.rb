class ChangeUserAttributes < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :name, default: ''
      t.string :phone_number

      t.remove :first_name
      t.remove :last_name
      t.remove :username
    end
  end
end
