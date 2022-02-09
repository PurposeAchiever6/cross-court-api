module Subscriptions
  class SendSubscriptionCanceledEvent
    include Interactor

    def call
      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::CANCELLED_MEMBERSHIP,
        context.user.id,
        cancelled_membership_name: context.subscription.product.name
      )
    end
  end
end
