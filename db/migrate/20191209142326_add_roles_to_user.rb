class AddRolesToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.boolean :is_referee, default: false, null: false, index: true
      t.boolean :is_sem, default: false, null: false, index: true
    end
  end
end
