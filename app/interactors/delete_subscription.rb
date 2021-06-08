class DeleteSubscription
  include Interactor

  def call
    subscription = context.subscription

    context.fail!(message: I18n.t('api.errors.subscriptions.is_not_active')) unless subscription&.active?

    stripe_subscription = StripeService.cancel_subscription(subscription)

    subscription.assign_stripe_attrs(stripe_subscription).save!
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
