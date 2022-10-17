module SessionGuests
  class Remove
    include Interactor

    def call
      user_session = context.user_session
      user = user_session.user
      session = user_session.session
      location = session.location

      session_guest = user_session.session_guests.find(context.session_guest_id)
      phone_number = session_guest.phone_number

      ::Sonar::SendMessageJob.perform_later(
        phone_number,
        I18n.t(
          'notifier.sonar.session_guests.removed',
          guest_name: session_guest.first_name,
          user_first_name: user.first_name,
          user_last_name: user.last_name,
          location: "#{location.name} (#{location.address})",
          date: user_session.date_when_format,
          time: user_session.time.strftime(Session::TIME_FORMAT)
        )
      )

      session_guest.update!(state: :canceled)
    end
  end
end
