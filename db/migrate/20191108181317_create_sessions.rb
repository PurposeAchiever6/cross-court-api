class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.string :name, null: false
      t.date :start_time, null: false
      t.text :recurring
      t.time :time, null: false
      t.timestamps
    end
  end
end
