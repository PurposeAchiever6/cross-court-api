module Api
  module V1
    module Sessions
      class WaitlistsController < Api::V1::ApiUserController
        def create
          @session = Session.find(params[:session_id])
          @date = date

          result = Waitlists::AddUser.call(
            session: @session,
            user: current_user,
            date: @date
          )

          render_error(:unprocessable_entity, result.error) if result.failure?
        end

        private

        def date
          date = params.require(:date)
          Date.strptime(date, '%m/%d/%Y')
        rescue ArgumentError
          raise WrongParameterException, I18n.t('api.errors.invalid_date_format')
        end
      end
    end
  end
end
