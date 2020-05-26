module Api
  module V1
    module Sem
      class UserSessionsController < Api::V1::ApiSemController
        after_action :send_klaviyo_event

        def check_in
          UserSession.where(id: checked_in_ids).update_all(checked_in: true)
          UserSession.where(id: not_checked_in_ids).update_all(checked_in: false)
        end

        private

        def klaviyo_service
          @klaviyo_service ||= KlaviyoService.new
        end

        def checked_in_ids
          @checked_in_ids ||= params[:checked_in_ids]
        end

        def not_checked_in_ids
          @not_checked_in_ids ||= params[:not_checked_in_ids]
        end

        def send_klaviyo_event
          KlaviyoCheckInUsers.perform_async(checked_in_ids)
        end
      end
    end
  end
end
