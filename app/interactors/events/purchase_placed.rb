module Events
  class PurchasePlaced
    include Interactor

    def call
      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::PURCHASE_PLACED,
        context.user.id,
        purchase_id: context.purchase.id
      )
    end
  end
end
