class SendSubscriptionCanceledEvent
  include Interactor

  def call
    CreateActiveCampaignDealJob.perform_now(
      ::ActiveCampaign::Deal::Event::CANCELLED_MEMBERSHIP,
      context.user.id,
      cancelled_membership_name: context.subscription.product.name
    )
  end
end
