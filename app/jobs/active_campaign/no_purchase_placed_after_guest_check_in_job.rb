module ActiveCampaign
  class NoPurchasePlacedAfterGuestCheckInJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :exponentially_longer, attempts: 2

    def perform(session_guest_id)
      session_guest = SessionGuest.find(session_guest_id)

      return if session_guest.user&.active_subscription&.present?

      temp_user = User.new(
        first_name: session_guest.first_name,
        last_name: session_guest.last_name,
        phone_number: session_guest.phone_number,
        email: session_guest.email
      )

      active_campaign_service = ActiveCampaignService.new(
        pipeline_name: ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      )

      response = active_campaign_service.create_update_contact(temp_user)

      contact = response['contact']
      active_campaign_id = contact['id']

      active_campaign_service.add_contact_to_list(
        ::ActiveCampaign::Contact::List::MASTER_LIST,
        active_campaign_id
      )

      temp_user.active_campaign_id = active_campaign_id

      active_campaign_service.create_deal(
        ActiveCampaign::Deal::Event::GUEST_CHECKED_IN_NO_PURCHASE_FIRST_TIME,
        temp_user
      )
    rescue ActiveCampaignException => e
      Rollbar.error(e)
    end
  end
end
