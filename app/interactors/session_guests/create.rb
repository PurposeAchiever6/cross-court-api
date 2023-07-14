module SessionGuests
  class Create
    include Interactor

    def call
      user_session = context.user_session
      user = user_session.user
      guest_info = context.guest_info
      session = user_session.session
      location = session.location

      guest_phone_number = context.phone_number
      guest_first_name = guest_info[:first_name].strip
      guest_last_name = guest_info[:last_name].strip
      guest_email = guest_info[:email].strip

      guest_attrs = {
        first_name: guest_first_name,
        last_name: guest_last_name,
        phone_number: guest_phone_number,
        email: guest_email
      }

      session_guest = SessionGuest.create!({ user_session: }.merge!(guest_attrs))

      ::ActiveCampaign::CreateUpdateContactAndAddToListJob.perform_later(nil, guest_attrs)

      ::Sonar::SendMessageJob.perform_later(
        guest_phone_number,
        I18n.t(
          'notifier.sonar.session_guests.added',
          guest_name: guest_first_name,
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
