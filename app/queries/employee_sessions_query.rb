class EmployeeSessionsQuery
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def future_sessions
    [
      user.sem_sessions
          .future
          .order(:date)
          .includes(session: [
                      location: [image_attachment: :blob]
                    ]),
      user.referee_sessions
          .future
          .order(:date)
          .includes(session: [
                      location: [image_attachment: :blob]
                    ])
    ].flatten.uniq { |session| "#{session[:session_id]} - #{session[:date]}" }
  end
end
