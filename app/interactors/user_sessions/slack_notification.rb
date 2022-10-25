module UserSessions
  class SlackNotification
    include Interactor

    def call
      from_waitlist = context.from_waitlist

      return if from_waitlist

      user_session = context.user_session
      user = user_session.user
      date = user_session.date
      time = user_session.time
      location = user_session.location

      SlackService.new(user, date, time, location).session_booked
    end
  end
end
