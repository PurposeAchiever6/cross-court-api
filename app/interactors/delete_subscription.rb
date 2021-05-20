class DeleteSubscription
  include Interactor

  def call
    subscription = context.subscription

    StripeService.cancel_subscription(subscription)
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
