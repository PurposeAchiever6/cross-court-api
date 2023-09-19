class CreateGoals < ActiveRecord::Migration[6.0]
  def up
    create_table :goals do |t|
      t.integer :category, null: false
      t.string :description, null: false
      t.timestamps
    end
  end

  def down
    drop_table :goals
  end
end
