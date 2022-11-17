class CreateShootingMachines < ActiveRecord::Migration[6.0]
  def change
    create_table :shooting_machines do |t|
      t.belongs_to :session
      t.float :price, default: 15
      t.time :start_time
      t.time :end_time
      t.timestamps
    end
  end
end
