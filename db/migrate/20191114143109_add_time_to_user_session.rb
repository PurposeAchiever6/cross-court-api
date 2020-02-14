class AddTimeToUserSession < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :date, :date

    UserSession.includes(:session).find_each do |user_session|
      user_session.update!(date: user_session.session.start_time)
    end

    change_column_null :user_sessions, :date, false
  end
end
