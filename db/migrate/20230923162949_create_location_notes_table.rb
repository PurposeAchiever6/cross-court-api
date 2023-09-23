class CreateLocationNotesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :location_notes do |t|
      t.text :notes
      t.date :date

      t.belongs_to :admin_user
      t.belongs_to :location

      t.timestamps
    end
  end
end
