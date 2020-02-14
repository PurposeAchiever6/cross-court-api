module Api
  module V1
    class UserSessionsController < Api::V1::ApiUserController
      def index
        @previous_sessions = user_sessions.past
                                          .order(date: :desc)
                                          .includes(session: [location: [image_attachment: :blob]])
                                          .take(3)
        @upcoming_sessions = user_sessions.future
                                          .order(:date)
                                          .includes(session: [location: [image_attachment: :blob]])
        @employee_upcoming_sessions = EmployeeSessionsQuery.new(current_user).future_sessions
      end

      def cancel
        ActiveRecord::Base.transaction do
          canceled_user_session = CanceledUserSession.new(user_session)
          canceled_user_session.save!
        end
      end

      def confirm
        ActiveRecord::Base.transaction do
          confirmed_user_session = ConfirmedUserSession.new(user_session)
          confirmed_user_session.save!
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
