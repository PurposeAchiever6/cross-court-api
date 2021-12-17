module Api
  module V1
    class SessionsController < Api::V1::ApiController
      include DeviseTokenAuth::Concerns::SetUserByToken

      helper_method :selected_session, :referee, :sem, :date

      before_action :log_user

      def show
        @user_session = selected_session.user_sessions
                                        .by_user(current_user)
                                        .by_date(date)
                                        .not_canceled
                                        .first
      end

      def index
        @user_sessions = UserSession.future.not_canceled.by_user(current_user)
                                    .group(:session_id, :date).count
        @sessions = SessionDecorator.decorate_collection(
          Session.eager_load(:location, :session_exceptions, :referee_sessions, :sem_sessions, :skill_level)
                 .by_location(params[:location_id])
                 .visible_for(current_user)
                 .for_range(from_date, to_date)
                 .flat_map do |session_event|
                   session_event.calendar_events(from_date, to_date)
                 end
        )
        @user_sessions_count = UserSession.where(date: (from_date..to_date))
                                          .group(:session_id, :date)
                                          .not_canceled
                                          .count
      end

      private

      def date
        @date = params[:date]
        @date = Date.parse(@date) if @date.present?
      end

      def from_date
        @from_date ||= Date.parse(params[:from_date]).beginning_of_week
      end

      def to_date
        @to_date ||= from_date.end_of_week
      end

      def selected_session
        @selected_session ||= Session.find(params[:id]).decorate
      end

      def referee
        @referee = selected_session.referee(params[:date])
      end

      def sem
        @sem = selected_session.sem(params[:date])
      end

      def log_user
        set_user_by_token(:user)
      end
    end
  end
end
