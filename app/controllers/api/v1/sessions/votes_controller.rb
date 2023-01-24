module Api
  module V1
    module Sessions
      class VotesController < Api::V1::ApiUserController
        def create
          @date = date
          @session = Session.find(params[:session_id])

          ::Sessions::Vote.call(
            session: @session,
            user: current_user,
            date: @date
          )

          head :ok
        end

        def destroy
          session = Session.find(params[:session_id])

          ::Sessions::RemoveVote.call(
            session:,
            user: current_user,
            date:
          )

          head :ok
        end

        private

        def date
          date = params.require(:date)
          Date.strptime(date, '%d/%m/%Y')
        rescue ArgumentError
          raise WrongParameterException, I18n.t('api.errors.invalid_date_format')
        end
      end
    end
  end
end
