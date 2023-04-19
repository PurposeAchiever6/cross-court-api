module Api
  module V1
    module Sessions
      class UserSessionsController < Api::V1::ApiUserController
        skip_before_action :authenticate_user!, only: :index

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
            shooting_machines:,
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

          Date.strptime(date, '%d/%m/%Y')
        end

        def shooting_machines
          ShootingMachine.where(id: params[:shooting_machine_ids])
        end
      end
    end
  end
end
