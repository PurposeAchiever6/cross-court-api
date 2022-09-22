class CreateUserUpdateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :user_update_requests do |t|
      t.integer :status, default: 0
      t.json :requested_attributes, default: {}
      t.text :reason

      t.belongs_to :user

      t.timestamps
    end

    add_index :user_update_requests, :status
  end
end
