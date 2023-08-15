module SessionGuests
  class NoShowUpJob < ApplicationJob
    queue_as :default

    def perform
      active_campaign_service = ActiveCampaignService.new(
        pipeline_name: ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      )

      SessionGuest.for_yesterday
                  .reserved
                  .not_checked_in
                  .find_each do |session_guest|
        session_guest.update!(state: :no_show)

        next unless session_guest.first_time?
        next if session_guest.user

        temp_user = User.new(
          first_name: session_guest.first_name,
          last_name: session_guest.last_name,
          phone_number: session_guest.phone_number,
          email: session_guest.email
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
          ActiveCampaign::Deal::Event::GUEST_NO_SHOW_FIRST_TIME,
          temp_user
        )
      rescue ActiveCampaignException => e
        Rollbar.error(e)
      end
    end
  end
end
