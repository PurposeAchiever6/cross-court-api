module Api
  module V1
    class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
      def show
        super
        KlaviyoService.new.event(Event::USER_CONFIRMATION, @resource)
      end
    end
  end
end
