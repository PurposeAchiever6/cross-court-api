module Events
  class PurchasePlaced
    include Interactor

    def call
      user_id = context.user.id

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::PURCHASE_PLACED,
        user_id,
        payment_id: context.payment.id
      )

      return unless context.product.trial?

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::PURCHASED_TRIAL,
        user_id,
        {},
        ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      )
    end
  end
end
