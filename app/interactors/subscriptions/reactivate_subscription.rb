module Subscriptions
  class ReactivateSubscription
    include Interactor

    def call
      subscription = context.subscription

      unless subscription.cancel_at_period_end
        context.fail!(message: I18n.t('api.errors.subscriptions.is_not_canceled'))
      end

      stripe_subscription = StripeService.reactivate_subscription(subscription)

      subscription = subscription.assign_stripe_attrs(stripe_subscription)
      subscription.mark_cancel_at_period_end_at = nil

      subscription.save!
    rescue Stripe::StripeError => e
      context.fail!(message: e.message)
    end
  end
end
