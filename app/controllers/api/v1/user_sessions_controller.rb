module Api
  module V1
    class UserSessionsController < Api::V1::ApiUserController
      def cancel
        user_session.canceled!
      end

      private

      def user_session
        current_user.user_sessions.find(params[:user_session_id])
      end
    end
  end
end
