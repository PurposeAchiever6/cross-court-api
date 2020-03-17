module Api
  module V1
    class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
      def show
        super do
          sign_in(@resource) if @resource.errors.empty?
        end
        KlaviyoService.new.event(Event::USER_CONFIRMATION, @resource)
      end
    end
  end
end
