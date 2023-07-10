module Users
  class CreateExternalIntegrations
    include Interactor

    def call
      user = context.user

      ActiveCampaignService.new.create_update_contact(user)
      ::ActiveCampaign::AddContactToListJob.perform_later(
        ::ActiveCampaign::Contact::List::MASTER_LIST,
        user.active_campaign_id
      )
      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::ACCOUNT_CREATION,
        user.id
      )

      StripeService.create_user(user)
      SonarService.add_update_customer(user)
    end
  end
end
