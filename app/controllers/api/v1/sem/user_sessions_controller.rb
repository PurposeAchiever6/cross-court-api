module Api
  module V1
    module Sem
      class UserSessionsController < Api::V1::ApiSemController
        def check_in
          UserSession.includes(:user, :session).where(id: params[:ids]).find_each do |user_session|
            user_session.update!(checked_in: true)
            klaviyo_service.event(Event::SESSION_CHECK_IN, user_session.user)
          end
        end

        private

        def klaviyo_service
          @klaviyo_service ||= KlaviyoService.new
        end
      end
    end
  end
end
