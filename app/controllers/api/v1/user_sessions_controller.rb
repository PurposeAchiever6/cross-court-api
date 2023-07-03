module Api
  module V1
    class UserSessionsController < Api::V1::ApiUserController
      def index
        @previous_sessions = user_sessions.past
                                          .reserved_or_confirmed
                                          .order(date: :desc)
                                          .order('sessions.time DESC')
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
                                          .order('sessions.time')
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

      def self_check_in
        UserSessions::SelfCheckIn.call(
          user_session_ids: params[:user_session_ids],
          qr_data: params[:qr_data]
        )

        head :no_content
      end

      def for_self_check_in
        @user_sessions = UserSessions::ForSelfCheckIn.call(
          location_id: params[:location_id],
          user: current_user
        ).user_sessions
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
