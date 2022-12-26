module Subscriptions
  class ChangePaymentMethod
    include Interactor

    def call
      subscription = context.subscription
      payment_method = context.payment_method
      payment_method_id = payment_method.id

      raise SubscriptionIsNotActiveException unless subscription.active? || subscription.paused?

      if subscription.payment_method_id != payment_method_id
        StripeService.update_subscription_payment_method(
          subscription,
          payment_method
        )

        subscription.update!(payment_method_id: payment_method_id)
      end

      context.subscription = subscription
    end
  end
end
