module SelfCheckIns
  class QrData
    include Interactor

    REFRESH_TIME = 1.hour

    def call
      time = Time.now.to_i
      location_id = context.location_id

      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])

      msg = crypt.encrypt_and_sign({ time:, location_id: })

      context.data = ERB::Util.url_encode(msg)
      context.refresh_time_ms = REFRESH_TIME.in_milliseconds
    end
  end
end
