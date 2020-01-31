require 'twilio-ruby'

class TwilioService
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  end

  def send_message(phone_number, message)
    client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: phone_number,
      body: message
    )
  ensure
    sleep 1
  end
end
