module SessionGuests
  class Validations
    include Interactor

    def call
      user_session = context.user_session
      guest_info = context.guest_info
      session = user_session.session
      date = user_session.date

      guests_allowed = session.guests_allowed
      guests_allowed_per_user = session.guests_allowed_per_user
      max_redemptions_by_guest = ENV.fetch('MAX_REDEMPTIONS_BY_GUEST', nil)

      phone_number = guest_info[:phone_number].strip
      email = guest_info[:email].strip

      if User.where(email:).or(User.where(phone_number:)).exists?
        raise SessionGuestsException, I18n.t('api.errors.session_guests.user_already_registered')
      end

      unless guests_allowed&.positive?
        raise SessionGuestsException, I18n.t('api.errors.session_guests.guests_not_allowed')
      end

      raise SessionGuestsException, I18n.t('api.errors.sessions.full') if session.full?(date)

      if session.guests_count(date) >= guests_allowed
        raise SessionGuestsException,
              I18n.t('api.errors.session_guests.max_guests_reached_for_session')
      end

      if guests_allowed_per_user \
         && user_session.session_guests.not_canceled.count >= guests_allowed_per_user
        raise SessionGuestsException,
              I18n.t('api.errors.session_guests.max_guests_reached_for_user')
      end

      if max_redemptions_by_guest
        times_invited_count = SessionGuest.not_canceled.for_phone(phone_number).count

        if times_invited_count >= max_redemptions_by_guest.to_i
          raise SessionGuestsException,
                I18n.t('api.errors.session_guests.max_redemptions_by_guest_reached')
        end
      end

      context.phone_number = phone_number
    end
  end
end
