class SendPurchasePlacedEvent
  include Interactor

  def call
    KlaviyoService.new.purchase_placed(context.purchase)
  end
end
