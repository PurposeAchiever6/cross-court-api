class AddStateToUserSessionWaitlists < ActiveRecord::Migration[6.0]
  def up
    add_column :user_session_waitlists, :state, :integer, default: 1

    UserSessionWaitlist.where(reached: true).update_all(state: :success)

    remove_column :user_session_waitlists, :reached
  end

  def down
    add_column :user_session_waitlists, :reached, :boolean, default: false

    UserSessionWaitlist.success.update_all(reached: true)

    remove_column :user_session_waitlists, :state
  end
end
