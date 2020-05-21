module Api
  module V1
    class SonarController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :verify_token

      def webhook
        send "handle_#{action}"
      end

      private

      def verify_token
        params[:company_publishable_key] == ENV['SONAR_PUBLISHABLE_KEY']
      end

      def action
        params[:sonar][:action]
      end

      def user
        User.find_by(email: params[:customer][:email])
      end

      def text
        params[:text]
      end

      def handle_new_unassigned_message
        SonarService.message_received(user, text)
      end
    end
  end
end
