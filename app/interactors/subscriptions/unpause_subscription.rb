module Subscriptions
  class UnpauseSubscription
    include Interactor

    def call
      subscription = context.subscription
      user = subscription.user

      raise SubscriptionIsNotPausedException unless subscription.paused?

      stripe_subscription = StripeService.unpause_subscription(subscription)
      subscription.assign_stripe_attrs(stripe_subscription).save!

      subscription.subscription_pauses.finished.last.update!(unpaused_at: Time.current)

      Subscriptions::RenewUserSubscriptionCredits.call(user: user, subscription: subscription)

      stripe_invoice = StripeService.retrieve_invoice(stripe_subscription.latest_invoice)
      discount_amount = stripe_invoice.total_discount_amounts.map(&:amount).reduce(:+) || 0

      Payments::Create.call(
        chargeable: subscription.product,
        user: user,
        amount: stripe_invoice.total / 100.00,
        description: subscription.name,
        payment_method: subscription.payment_method,
        payment_intent_id: stripe_invoice.payment_intent,
        discount: discount_amount / 100.00
      )

      SlackService.new(user).subscription_unpaused(subscription)
    end
  end
end
