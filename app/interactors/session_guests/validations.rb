module SessionGuests
  class Validations
    include Interactor

    def call
      user_session = context.user_session
      guest_info = context.guest_info
      session = user_session.session

      guests_allowed = session.guests_allowed
      guests_allowed_per_user = session.guests_allowed_per_user
      max_redemptions_by_guest = ENV['MAX_REDEMPTIONS_BY_GUEST']&.to_i

      unless guests_allowed&.positive?
        raise SessionGuestsException, I18n.t('api.errors.session_guests.guests_not_allowed')
      end

      user_sessions_ids = session.user_sessions.by_date(user_session.date).ids
      sessions_guests_count = SessionGuest.where(
        user_session_id: user_sessions_ids
      ).not_canceled.count

      if guests_allowed && sessions_guests_count >= guests_allowed
        raise SessionGuestsException,
              I18n.t('api.errors.session_guests.max_guests_reached_for_session')
      end

      if guests_allowed_per_user &&
         user_session.session_guests.not_canceled.count >= guests_allowed_per_user
        raise SessionGuestsException,
              I18n.t('api.errors.session_guests.max_guests_reached_for_user')
      end

      phone_number = guest_info[:phone_number].strip

      times_invited_count = SessionGuest.not_canceled.for_phone(phone_number).count

      if max_redemptions_by_guest && times_invited_count >= max_redemptions_by_guest
        raise SessionGuestsException,
              I18n.t('api.errors.session_guests.max_redemptions_by_guest_reached')
      end

      context.phone_number = phone_number
    end
  end
end
