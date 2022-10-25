module Api
  module V1
    class SubscriptionsController < Api::V1::ApiUserController
      def create
        result = Subscriptions::PlaceSubscription.call(
          product: product,
          user: current_user,
          payment_method: payment_method,
          promo_code: promo_code,
          description: product.name
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

        @subscription = result.subscription
      end

      def preview_prorate
        @invoice = Subscriptions::ProratePrice.call(
          user: current_user,
          new_product: product,
          promo_code: promo_code
        ).invoice
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
          user: current_user,
          subscription: subscription
        )

        raise SubscriptionException, result.message unless result.success?

        @subscription = result.subscription
      end

      def change_payment_method
        result = Subscriptions::ChangePaymentMethod.call(
          subscription: subscription,
          payment_method: payment_method
        )

        @subscription = result.subscription
      end

      def request_cancellation
        Subscriptions::CreateCancellationRequest.call(
          subscription_cancellation_request_params.merge(user: current_user)
        )
        head :no_content
      end

      def pause
        result = Subscriptions::PauseSubscription.call(
          subscription: subscription,
          months: params[:months],
          reason: params[:reason]
        )

        @subscription = result.subscription
      end

      def cancel_pause
        result = Subscriptions::CancelSubscriptionPause.call(subscription: subscription)

        @subscription = result.subscription
      end

      def unpause
        result = Subscriptions::UnpauseSubscription.call(subscription: subscription)

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
        params.permit(:experiencie_rate, :service_rate, :recommend_rate, :reason)
      end
    end
  end
end
