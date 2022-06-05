class CreateUserSessionVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :user_session_votes do |t|
      t.date :date

      t.references :user
      t.references :session

      t.timestamps
    end

    add_index :user_session_votes, %i[date session_id user_id], unique: true
  end
end
