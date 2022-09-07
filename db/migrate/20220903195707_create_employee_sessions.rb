class CreateEmployeeSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :employee_sessions do |t|
      t.references :user, null: false, index: true
      t.references :session, null: true, index: true
      t.date :date, null: false
      t.integer :state, null: false, default: 0
      t.string :type, null: false

      t.timestamps
    end
  end
end
