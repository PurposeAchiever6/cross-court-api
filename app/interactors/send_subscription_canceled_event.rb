class SendSubscriptionCanceledEvent
  include Interactor

  def call
    KlaviyoService.new.event(Event::MEMBERSHIP_CANCELED, context.user, membership_name: context.subscription.product.name)
  end
end
