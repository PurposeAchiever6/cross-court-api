module Api
  module V1
    module Sessions
      class UserSessionsController < Api::V1::ApiUserController
        def index
          @user_sessions =
            Session.find(params[:session_id])
                   .not_canceled_reservations(date)
                   .where(checked_in: checked_in)
                   .includes(:session, user: { image_attachment: :blob })
                   .order(:created_at)
        end

        def create
          session = Session.find(params[:session_id])

          UserSessions::Create.call(
            referral_code: params[:referral_code],
            session: session,
            user: current_user,
            date: params[:date]
          )
        end

        private

        def checked_in
          params[:checked_in] == 'true' ? true : [true, false]
        end

        def date
          date = params[:date]
          return Time.zone.today unless date

          Date.strptime(date, '%m/%d/%Y')
        end
      end
    end
  end
end
