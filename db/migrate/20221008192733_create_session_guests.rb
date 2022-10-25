class CreateSessionGuests < ActiveRecord::Migration[6.0]
  def change
    create_table :session_guests do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number, null: false
      t.string :email, null: false
      t.string :access_code, null: false
      t.integer :state, null: false, default: 0
      t.belongs_to :user_session

      t.timestamps
    end
  end
end
