module SessionGuests
  class NoShowUpJob < ApplicationJob
    queue_as :default

    def perform
      SessionGuest.for_yesterday
                  .reserved
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

        ActiveCampaignService.new(
          pipeline_name: ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
        ).create_deal(
          ActiveCampaign::Deal::Event::GUEST_NO_SHOW_FIRST_TIME,
          temp_user
        )
      rescue ActiveCampaignException => e
        Rollbar.error(e)
      end
    end
  end
end
