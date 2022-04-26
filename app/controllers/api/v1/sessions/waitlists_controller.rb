module Api
  module V1
    module Sessions
      class WaitlistsController < Api::V1::ApiUserController
        def create
          @date = date
          @session = Session.includes(location: { images_attachments: :blob })
                            .find(params[:session_id])

          Waitlists::AddUser.call(
            session: @session,
            user: current_user,
            date: @date
          )
        end

        def destroy
          session = Session.find(params[:session_id])

          Waitlists::RemoveUser.call(
            session: session,
            user: current_user,
            date: date
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
