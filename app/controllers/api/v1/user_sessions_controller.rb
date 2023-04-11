module Api
  module V1
    class UserSessionsController < Api::V1::ApiUserController
      def index
        @previous_sessions = user_sessions.past
                                          .reserved_or_confirmed
                                          .order(date: :desc)
                                          .includes(
                                            :session_survey,
                                            session: [
                                              :skill_level,
                                              { location: [images_attachments: :blob] }
                                            ]
                                          )
                                          .take(3)
        @upcoming_sessions = user_sessions.future
                                          .reserved_or_confirmed
                                          .order(:date)
                                          .includes(
                                            :session_survey,
                                            session: [
                                              :skill_level,
                                              { location: [images_attachments: :blob] }
                                            ]
                                          )
        @employee_upcoming_sessions = EmployeeSessionsQuery.new(current_user).sorted_future_sessions
      end

      def cancel
        UserSessions::Cancel.call(user_session:)
      end

      def confirm
        ActiveRecord::Base.transaction do
          confirmed_user_session = UserSessionConfirmed.new(user_session)
          confirmed_user_session.save!
        end
      end

      private

      def user_sessions
        current_user.user_sessions
      end

      def user_session
        @user_session ||= current_user.user_sessions.find(params[:user_session_id])
      end
    end
  end
end
