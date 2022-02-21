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
        @payment_methods = current_user.payment_methods.order(:created_at)
      end

      def destroy
        Users::DestroyPaymentMethod.call(payment_method_id: params[:id], user: current_user)
      end

      def update
        payment_methods = current_user.payment_methods

        if default_update?
          current_user.default_payment_method.update!(default: false)
          payment_methods.find(params[:id]).update!(update_params)
        end

        @payment_methods = payment_methods.order(:created_at)
      end

      private

      def update_params
        params.require(:payment_method).permit(:default)
      end

      def default_update?
        update_params.key?(:default)
      end
    end
  end
end
