module UserSessions
  class SelfCheckIn
    include Interactor

    def call
      user_session_ids = context.user_session_ids
      qr_data = context.qr_data

      user_sessions = UserSession.where(id: user_session_ids).includes(:session)

      user_sessions_location_ids = user_sessions.map do |user_session|
        user_session.session.location_id
      end

      raise SelfCheckInQrInvalidException unless qr_valid?(qr_data, user_sessions_location_ids)

      user_sessions.includes(:user).each { |user_session| user_session.update!(checked_in: true) }

      ::Sessions::CheckInUsersJob.perform_later(user_session_ids, checked_in_at: Time.now.to_i)
      ::Sonar::FirstSessionSmsJob.perform_later(user_session_ids)
    end

    private

    def qr_valid?(qr_data, user_sessions_location_ids)
      location_id = if user_sessions_location_ids.length == 1
                      user_sessions_location_ids.first
                    else
                      user_sessions_location_ids.uniq!&.first
                    end

      return false if location_id.nil?

      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])

      decrypted_data = crypt.decrypt_and_verify(qr_data)
      decrypted_time = decrypted_data[:time]
      decrypted_location_id = decrypted_data[:location_id]

      current_time = Time.zone.at(Time.now.to_i)
      self_check_in_window = SelfCheckIns::QrData::REFRESH_TIME + 10.minutes

      current_time < Time.zone.at(decrypted_time) + self_check_in_window &&
        decrypted_location_id.to_i == location_id
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      false
    end
  end
end
