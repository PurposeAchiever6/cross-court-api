class CreateLateArrivals < ActiveRecord::Migration[7.0]
  def change
    create_table :late_arrivals do |t|
      t.references :user
      t.references :user_session
      t.timestamps

      t.index %i[user_id user_session_id], unique: true
    end
  end
end
