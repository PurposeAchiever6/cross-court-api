module Api
  module V1
    class UserSessionsController < Api::V1::ApiUserController
      def index
        @previous_sessions = user_sessions.past.order(date: :desc).includes(session: :location)
        @upcoming_sessions = user_sessions.future.order(:date).includes(session: :location)
      end

      def cancel
        user_session.canceled!
      end

      private

      def user_sessions
        current_user.user_sessions
      end

      def user_session
        current_user.user_sessions.find(params[:user_session_id])
      end
    end
  end
end
