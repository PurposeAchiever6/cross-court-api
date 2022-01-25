module Api
  module V1
    class SubscriptionsController < Api::V1::ApiUserController
      def create
        result = Subscriptions::PlaceSubscription.call(
          product: product,
          user: current_user,
          payment_method: payment_method,
          promo_code: promo_code
        )

        raise SubscriptionException, result.message unless result.success?

        @subscription = result.subscription
      end

      def index
        @subscriptions = current_user.subscriptions.order(id: :desc)
      end

      def destroy
        result = Subscriptions::CancelSubscriptionAtPeriodEnd.call(
          user: current_user,
          subscription: subscription
        )

        raise SubscriptionException, result.message unless result.success?

        @subscription = result.subscription
      end

      def update
        result = Subscriptions::UpdateSubscription.call(
          user: current_user,
          subscription: subscription,
          product: product,
          payment_method: payment_method,
          promo_code: promo_code
        )

        raise SubscriptionException, result.message unless result.success?

        @subscription = result.subscription
      end

      def reactivate
        result = Subscriptions::SubscriptionReactivation.call(
          user: current_user, subscription: subscription
        )

        raise SubscriptionException, result.message unless result.success?

        @subscription = result.subscription
      end

      private

      def product
        Product.find(params[:product_id])
      end

      def promo_code
        PromoCode.find_by(code: params[:promo_code])
      end

      def payment_method
        params.require(:payment_method)
      end

      def subscription
        current_user.subscriptions.find(params[:id])
      end
    end
  end
end
