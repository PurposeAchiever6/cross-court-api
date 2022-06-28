module Events
  class PurchasePlaced
    include Interactor

    def call
      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::PURCHASE_PLACED,
        context.user.id,
        payment_id: context.payment.id
      )
    end
  end
end
