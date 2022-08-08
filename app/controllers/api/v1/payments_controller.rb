module Api
  module V1
    class PaymentsController < Api::V1::ApiUserController
      before_action :validate_free_session, only: :create_free_session_intent

      def index
        @payments = current_user.payments.order(id: :desc).page(page)
      end

      # TODO: move these two endpoints to a 'drop_ins' controller or something like that
      def create
        result = PlacePurchase.call(
          product: product,
          user: current_user,
          payment_method: payment_method,
          promo_code: promo_code,
          description: "#{product.name} purchase",
          use_cc_cash: use_cc_cash
        )

        raise PaymentException, result.message unless result.success?
      end

      def create_free_session_intent
        result = Users::ClaimFreeSession.call(
          user: current_user,
          payment_method: payment_method
        )

        raise ClaimFreeSessionException, result.message unless result.success?
      end

      private

      def page
        params[:page] || 1
      end

      def product
        Product.find(params[:product_id])
      end

      def promo_code
        PromoCode.find_by(code: params[:promo_code])
      end

      def payment_method_id
        params.require(:payment_method_id)
      end

      def payment_method
        current_user.payment_methods.find(payment_method_id)
      end

      def use_cc_cash
        params[:use_cc_cash]
      end

      def validate_free_session
        return if current_user.free_session_not_claimed?

        raise InvalidActionException, t('api.errors.free_session')
      end
    end
  end
end
