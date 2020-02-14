class CreateSessionExceptions < ActiveRecord::Migration[6.0]
  def change
    create_table :session_exceptions do |t|
      t.references :session, null: false, index: true
      t.datetime :date, null: false
      t.timestamps
    end

    add_index :session_exceptions, %i[date session_id]
  end
end
