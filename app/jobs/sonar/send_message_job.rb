module Sonar
  class SendMessageJob < ApplicationJob
    queue_as :default

    def perform(phone, message)
      SonarService.send_message_to_phone(phone, message)
    end
  end
end
