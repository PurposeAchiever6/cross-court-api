module Api
  module V1
    module Sem
      class UserSessionsController < Api::V1::ApiSemController
        def check_in
          user_sessions.where(id: params[:checked_in_ids]).find_each do |user_session|
            user_session.update!(checked_in: true)
            klaviyo_service.event(Event::SESSION_CHECK_IN, user_session.user)
          end
          user_sessions.where(id: params[:not_checked_in_ids]).find_each do |user_session|
            user_session.update!(checked_in: false)
          end
        end

        private

        def user_sessions
          @user_sessions = UserSession.includes(:user, :session)
        end

        def klaviyo_service
          @klaviyo_service ||= KlaviyoService.new
        end
      end
    end
  end
end
