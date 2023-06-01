class AddSignupStateToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :signup_state, :integer, default: 0

    User.update_all(signup_state: :completed)
  end

  def down
    remove_column :users, :signup_state
  end
end
