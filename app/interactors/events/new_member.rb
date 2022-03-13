module Events
  class NewMember
    include Interactor

    def call
      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::NEW_MEMBER,
        context.user.id,
        subscription_name: context.product.name
      )
    end
  end
end
