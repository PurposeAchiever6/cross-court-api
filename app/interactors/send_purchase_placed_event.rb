class SendPurchasePlacedEvent
  include Interactor

  def call
    CreateActiveCampaignDealJob.perform_later(
      ::ActiveCampaign::Deal::Event::PURCHASE_PLACED,
      context.user.id,
      purchase_id: context.purchase.id
    )
  end
end
