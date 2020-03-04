class SendPurchasePlacedEvent
  include Interactor

  def call
    KlaviyoService.new.event(Event::PURCHASE_PLACED, context.user, purchase: context.purchase)
  end
end
