module Api
  module V1
    class SubscriptionsController < Api::V1::ApiUserController
      def index
        @subscriptions = current_user.subscriptions.order(id: :desc)
      end

      def create
        result = Subscriptions::PlaceSubscription.call(
          product:,
          user: current_user,
          payment_method:,
          promo_code:,
          description: product.name
        )

        raise SubscriptionException, result.message unless result.success?

        @subscription = result.subscription
      end

      def update
        result = Subscriptions::UpdateSubscription.call(
          user: current_user,
          subscription:,
          product:,
          payment_method:,
          promo_code:
        )

        raise SubscriptionException, result.message unless result.success?

        @subscription = result.subscription
      end

      def destroy
        result = Subscriptions::CancelSubscriptionAtPeriodEnd.call(
          user: current_user,
          subscription:
        )

        @subscription = result.subscription
      end

      def preview_prorate
        @invoice = Subscriptions::ProratePrice.call(
          user: current_user,
          new_product: product,
          promo_code:
        ).invoice
      end

      def reactivate
        result = Subscriptions::SubscriptionReactivation.call(
          user: current_user,
          subscription:
        )

        raise SubscriptionException, result.message unless result.success?

        @subscription = result.subscription
      end

      def change_payment_method
        result = Subscriptions::ChangePaymentMethod.call(
          subscription:,
          payment_method:
        )

        @subscription = result.subscription
      end

      def remove_cancel_at_next_period_end
        Subscriptions::RemoveScheduledCancellation.call(
          subscription:
        )

        @subscription = subscription
      end

      def request_cancellation
        result = Subscriptions::CreateCancellationRequest.call(
          subscription_cancellation_request_params.merge(user: current_user)
        )

        @subscription = result.subscription
      end

      def cancel_request_cancellation
        result = Subscriptions::CancelCancellationRequest.call(
          user: current_user
        )

        @subscription = result.subscription
      end

      def pause
        result = Subscriptions::PauseSubscription.call(
          subscription:,
          reason: params[:reason]
        )

        @subscription = result.subscription
      end

      def cancel_pause
        result = Subscriptions::CancelSubscriptionPause.call(subscription:)

        @subscription = result.subscription
      end

      def unpause
        result = Subscriptions::UnpauseSubscription.call(subscription:)

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
        current_user.payment_methods.find(params[:payment_method_id])
      end

      def subscription
        current_user.subscriptions.find(params[:id])
      end

      def subscription_cancellation_request_params
        params.permit(:reason)
      end
    end
  end
end
