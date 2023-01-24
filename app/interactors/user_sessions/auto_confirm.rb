module UserSessions
  class AutoConfirm
    include Interactor

    def call
      from_waitlist = context.from_waitlist || false

      return if from_waitlist

      user_session = context.user_session
      user = user_session.user
      session = user_session.session
      shooting_machine_reservation = user_session.shooting_machine_reservation

      return if user_session.in_cancellation_time?

      user_session.state = :confirmed

      if !user_session.reminder_sent_at && !session.is_open_club?
        SonarService.send_message(user, message_text(user_session))
        user_session.reminder_sent_at = Time.zone.now
      end

      if shooting_machine_reservation
        ShootingMachineReservations::Confirm.call(
          shooting_machine_reservation:
        )
      end

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
        user.id,
        user_session_id: user_session.id
      )

      user_session.save!
    end

    private

    def invite_friend(user_session)
      date = user_session.date
      user = user_session.user
      session = user_session.session
      invite_link = user_session.invite_link

      return '' if session.full?(date, user)

      I18n.t('notifier.sonar.invite_friend', link: invite_link)
    end

    def message_text(user_session)
      user = user_session.user
      time = user_session.time.strftime(Session::TIME_FORMAT)
      location = user_session.location
      first_session = user_session.first_session
      name = user.first_name

      i18n_message_key = if first_session
                           'notifier.sonar.session_auto_confirmed_first_timers'
                         else
                           'notifier.sonar.session_auto_confirmed'
                         end

      I18n.t(i18n_message_key,
             name:,
             time:,
             location: location.name,
             frontend_url: ENV.fetch('FRONTENT_URL', nil),
             invite_friend: invite_friend(user_session))
    end
  end
end
