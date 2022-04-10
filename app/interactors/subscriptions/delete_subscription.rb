module Subscriptions
  class DeleteSubscription
    include Interactor

    def call
      subscription = context.subscription

      raise SubscriptionAlreadyCanceledException if subscription.canceled?

      stripe_subscription = StripeService.cancel_subscription(subscription)

      subscription.assign_stripe_attrs(stripe_subscription).save!
    end
  end
end
