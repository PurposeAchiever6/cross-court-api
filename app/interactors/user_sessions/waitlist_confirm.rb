module UserSessions
  class WaitlistConfirm
    include Interactor

    def call
      from_waitlist = context.from_waitlist

      return unless from_waitlist

      user_session = context.user_session
      user = user_session.user
      date = user_session.date
      time = user_session.time
      location = user_session.location

      user_session.state = :confirmed

      SonarService.send_message(user, session_waitlist_confirmed_message(user_session))

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
        user.id,
        user_session_id: user_session.id
      )

      SlackService.new(user, date, time, location).session_waitlist_confirmed

      user_session.save!
    end

    private

    def session_waitlist_confirmed_message(user_session)
      user = user_session.user
      location = user_session.location

      I18n.t(
        'notifier.sonar.session_waitlist_confirmed',
        name: user.first_name,
        when: user_session.date_when_format,
        time: user_session.time.strftime(Session::TIME_FORMAT),
        location: "#{location.name} (#{location.address})"
      )
    end
  end
end
