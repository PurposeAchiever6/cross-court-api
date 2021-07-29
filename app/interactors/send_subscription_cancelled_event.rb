class SendSubscriptionCancelledEvent
  include Interactor

  def call
    KlaviyoService.new.event(Event::MEMBERSHIP_CANCELLED, context.user, membership_name: context.subscription.product.name)
  end
end
