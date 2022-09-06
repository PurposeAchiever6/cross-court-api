class EmployeeSessionsQuery
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def sorted_future_sessions
    future_sessions.sort do |s1, s2|
      if s1.date == s2.date
        s1.time - s2.time
      else
        s1.date - s2.date
      end
    end
  end

  private

  def future_sessions
    [
      user.sem_sessions
          .future
          .order(:date)
          .includes(session: [
                      location: [images_attachments: :blob]
                    ]),
      user.referee_sessions
          .future
          .order(:date)
          .includes(session: [
                      location: [images_attachments: :blob]
                    ]),
      user.coach_sessions
          .future
          .order(:date)
          .includes(session: [
                      location: [images_attachments: :blob]
                    ])
    ].flatten.uniq { |session| "#{session[:session_id]} - #{session[:date]}" }
  end
end
