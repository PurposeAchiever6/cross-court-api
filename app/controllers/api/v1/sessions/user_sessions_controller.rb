module Api
  module V1
    module Sessions
      class UserSessionsController < Api::V1::ApiUserController
        def index
          @user_sessions =
            Session.find(params[:session_id])
                   .user_sessions
                   .where(date: date, checked_in: true)
                   .includes(:user, user: :image_attachment).order(:created_at)
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

        def date
          date = params[:date]
          return Time.zone.today unless date

          Date.strptime(date, '%m/%d/%Y')
        end
      end
    end
  end
end
