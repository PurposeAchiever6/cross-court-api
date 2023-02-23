module UserSessions
  class NoShow
    include Interactor

    def call
      user_session = context.user_session
      user = user_session.user
      session = user_session.session
      location = session.location

      UserSessions::ChargeNoShow.call(user_session:)

      user_session.update!(state: :no_show)

      SonarService.send_message(
        user,
        I18n.t(
          'notifier.sonar.no_show',
          name: user.first_name,
          time: session.time.strftime(Session::TIME_FORMAT),
          location: location.name
        )
      )

      SlackService.new(user, user_session.date, user_session.time, user_session.location).no_show
    end
  end
end
