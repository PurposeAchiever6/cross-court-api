module Api
  module V1
    class PaymentMethodsController < Api::V1::ApiUserController
      def create
        StripeService.create_payment_method(params[:payment_method], current_user)
      end

      def index
        @payment_methods = StripeService.fetch_payment_methods(current_user)
      end

      def destroy
        StripeService.destroy_payment_method(params[:id])
      end
    end
  end
end