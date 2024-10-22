module Api
  module V1
    class SessionsController < Api::V1::ApiController
      include DeviseTokenAuth::Concerns::SetUserByToken

      helper_method :selected_session, :referee, :sem, :coach, :date

      before_action :log_user

      def index
        @user_sessions = UserSession.future.reserved_or_confirmed.by_user(current_user)
                                    .group(:session_id, :date).count

        @user_sessions_waitlists = UserSessionWaitlist.pending
                                                      .by_user(current_user)
                                                      .group(:session_id, :date)
                                                      .count

        @user_sessions_votes = UserSessionVote.by_user(current_user)
                                              .group(:session_id, :date).count

        @sessions = Session.includes(:location, :session_exceptions, :skill_level, :products)
                           .by_location(params[:location_id])
                           .visible_for(current_user)
                           .for_range(from_date, to_date)
                           .flat_map do |session_event|
                             session_event.calendar_events(from_date, to_date)
                           end
      end

      def show
        @user_session = selected_session.user_sessions
                                        .by_user(current_user)
                                        .by_date(date)
                                        .reserved_or_confirmed
                                        .first

        @on_waitlist = selected_session.waitlist(date).pending.by_user(current_user).exists?
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
        @selected_session ||= Session.with_deleted.find(params[:id]).decorate
      end

      def referee
        @referee = selected_session.referee(params[:date])
      end

      def sem
        @sem = selected_session.sem(params[:date])
      end

      def coach
        @coach = selected_session.coach(params[:date])
      end

      def log_user
        set_user_by_token(:user)
      end
    end
  end
end
