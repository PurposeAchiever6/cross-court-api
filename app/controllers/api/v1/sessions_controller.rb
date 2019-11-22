module Api
  module V1
    class SessionsController < Api::V1::ApiController
      helper_method :selected_session

      def show; end

      def index
        @sessions = Session.includes(:location)
                           .by_location(params[:location_id])
                           .for_range(from_date, to_date)
                           .flat_map do |meeting|
          meeting.calendar_events(from_date, to_date)
        end
      end

      private

      def from_date
        @from_date ||= Date.parse(params[:from_date])
      end

      def to_date
        @to_date ||= from_date.end_of_week
      end

      def selected_session
        @selected_session ||= Session.find(params[:id])
      end
    end
  end
end
