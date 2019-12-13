module Api
  module V1
    class UserSessionsController < Api::V1::ApiUserController
      def index
        @previous_sessions = user_sessions.past
                                          .order(date: :desc)
                                          .includes(session: [location: [image_attachment: :blob]])
        @upcoming_sessions = user_sessions.future
                                          .order(:date)
                                          .includes(session: [location: [image_attachment: :blob]])
      end

      def cancel
        ActiveRecord::Base.transaction do
          canceled_user_session = CanceledUserSession.new(user_session)
          canceled_user_session.save!
        end
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
