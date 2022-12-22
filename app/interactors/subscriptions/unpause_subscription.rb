module Subscriptions
  class UnpauseSubscription
    include Interactor

    def call
      subscription = context.subscription
      user = subscription.user

      raise SubscriptionIsNotPausedException unless subscription.paused?

      stripe_subscription = StripeService.unpause_subscription(subscription)
      subscription.assign_stripe_attrs(stripe_subscription).save!

      stripe_invoice = StripeService.retrieve_invoice(stripe_subscription.latest_invoice)
      discount_amount = stripe_invoice.total_discount_amounts.map(&:amount).reduce(:+) || 0

      status = :success
      error_message = nil

      payment_failed = stripe_subscription.status == 'past_due'

      subscription_pauses = subscription.subscription_pauses

      if payment_failed
        stripe_charge = StripeService.retrieve_charge(stripe_invoice.charge)

        status = :error
        error_message = stripe_charge.failure_message

        Subscriptions::CancelSubscription.call(user: user, subscription: subscription)

        SlackService.new(user).subscription_unpause_failed_payment(subscription)
      else
        subscription_pauses.finished.last.update!(unpaused_at: Time.current)

        Subscriptions::RenewUserSubscriptionCredits.call(user: user, subscription: subscription)

        SlackService.new(user).subscription_unpaused(subscription)
      end

      Payments::Create.call(
        chargeable: subscription.product,
        user: user,
        amount: stripe_invoice.total / 100.00,
        status: status,
        error_message: error_message,
        description: subscription.name,
        payment_method: subscription.payment_method,
        payment_intent_id: stripe_invoice.payment_intent,
        discount: discount_amount / 100.00
      )

      return unless payment_failed

      raise PaymentException,
            "The payment failed with message: '#{error_message}'. " \
            'Your membership was canceled. ' \
            'Please review your payment methods.'
    end
  end
end
