module SessionGuests
  class Create
    include Interactor

    def call
      user_session = context.user_session
      user = user_session.user
      guest_info = context.guest_info
      session = user_session.session
      location = session.location
      phone_number = context.phone_number
      guest_name = guest_info[:first_name].strip

      session_guest = SessionGuest.create!(
        user_session: user_session,
        first_name: guest_name,
        last_name: guest_info[:last_name].strip,
        phone_number: phone_number,
        email: guest_info[:email].strip
      )

      ::Sonar::SendMessageJob.perform_later(
        phone_number,
        I18n.t(
          'notifier.sonar.session_guests.added',
          guest_name: guest_name,
          user_first_name: user.first_name,
          user_last_name: user.last_name,
          location: "#{location.name} (#{location.address})",
          date: user_session.date_when_format,
          time: user_session.time.strftime(Session::TIME_FORMAT),
          access_code: session_guest.access_code
        )
      )

      context.session_guest = session_guest
    end
  end
end
