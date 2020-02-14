module Api
  module V1
    class PurchasesController < Api::V1::ApiUserController
      before_action :validate_free_session, only: :claim_free_session

      def index
        @purchases = current_user.purchases.order(id: :desc)
      end

      def create
        StripeService.charge(current_user, payment_method, product)
      end

      def claim_free_session
        intent = StripeService.create_free_session_intent(current_user, payment_method)
        current_user.free_session_state = :claimed
        current_user.free_session_payment_intent = intent.id
        current_user.increment(:credits)
        current_user.save!
      end

      private

      def product
        Product.find_by(stripe_id: params[:product_id])
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
