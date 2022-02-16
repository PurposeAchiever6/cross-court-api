module Api
  module V1
    class PaymentMethodsController < Api::V1::ApiUserController
      def create
        @payment_method = Users::CreatePaymentMethod.call(
          payment_method_stripe_id: params[:payment_method_stripe_id],
          user: current_user
        ).payment_method
      end

      def index
        @payment_methods = current_user.payment_methods
      end

      def destroy
        Users::DestroyPaymentMethod.call(payment_method_id: params[:id], user: current_user)
      end
    end
  end
end
