module Api
  module V1
    module Sessions
      class UserSessionsController < Api::V1::ApiUserController
        def index
          @user_sessions =
            Session.find(params[:session_id])
                   .not_canceled_reservations(date)
                   .where(checked_in:)
                   .includes(:session, user: { image_attachment: :blob })
                   .order(:created_at)
        end

        def create
          session = Session.find(params[:session_id])

          @user_session = UserSessions::Create.call(
            referral_code: params[:referral_code],
            session:,
            user: current_user,
            shooting_machine:,
            date: params[:date],
            goal: params[:goal],
            scouting: params[:scouting]
          ).user_session
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

        def shooting_machine
          ShootingMachine.find_by(id: params[:shooting_machine_id])
        end
      end
    end
  end
end
