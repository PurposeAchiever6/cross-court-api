module Api
  module V1
    class SubscriptionsController < Api::V1::ApiUserController
      def create
        result = PlaceSubscription.call(
          product: product,
          user: current_user,
          payment_method: payment_method
        )
        raise SubscriptionException, result.message unless result.success?
      end

      def index
        @subscriptions = current_user.subscriptions.order(id: :desc)
      end

      def destroy
        result = CancelSubscription.call(
          user: current_user,
          subscription: subscription
        )

        raise SubscriptionException, result.message unless result.success?
      end

      def update
        StripeService.update_subscription(subscription, product, payment_method)
      end

      private

      def product
        Product.find(params[:product_id])
      end

      def payment_method
        params.require(:payment_method)
      end

      def subscription
        Subscription.find(params[:id])
      end
    end
  end
end