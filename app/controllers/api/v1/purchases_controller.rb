module Api
  module V1
    class PurchasesController < Api::V1::ApiUserController
      before_action :validate_free_session, only: :create_free_session_intent

      def index
        @purchases = current_user.purchases.order(id: :desc).decorate
      end

      def create
        result = PlacePurchase.call(
          product: product,
          user: current_user,
          payment_method: payment_method,
          promo_code: promo_code
        )
        raise PurchaseException, result.message unless result.success?
      end

      def create_free_session_intent
        intent = StripeService.create_free_session_intent(current_user, payment_method)
        current_user.free_session_state = :claimed
        current_user.free_session_payment_intent = intent.id
        current_user.save!
        KlaviyoService.new.event(Event::CLAIMED_FREE_SESSION, current_user)
      end

      private

      def product
        Product.find_by(stripe_id: params[:product_id])
      end

      def promo_code
        PromoCode.find_by(code: params[:promo_code])
      end

      def payment_method
        params.require(:payment_method)
      end

      def validate_free_session
        return if current_user.free_session_not_claimed?

        raise InvalidActionException, t('api.errors.free_session')
      end
    end
  end
end
