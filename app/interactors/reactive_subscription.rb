class ReactiveSubscription
  include Interactor

  def call
    subscription = context.subscription

    context.fail!(message: I18n.t('api.errors.subscriptions.is_not_canceled')) unless subscription.cancel_at_period_end

    stripe_subscription = StripeService.reactive_subscription(subscription)

    subscription.assign_stripe_attrs(stripe_subscription).save!
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
