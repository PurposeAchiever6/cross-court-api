class CreateLegals < ActiveRecord::Migration[6.0]
  def change
    create_table :legals do |t|
      t.string :title, null: false, unique: true, index: true
      t.text :text, null: false
      t.timestamps
    end
  end
end
