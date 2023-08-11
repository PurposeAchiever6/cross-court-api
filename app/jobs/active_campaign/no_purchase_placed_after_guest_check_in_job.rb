module ActiveCampaign
  class NoPurchasePlacedAfterGuestCheckInJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :exponentially_longer, attempts: 2

    def perform(session_guest_id)
      session_guest = SessionGuest.find(session_guest_id)

      guest_email = session_guest.email
      guest_phone_number = session_guest.phone_number

      user = User.where(email: guest_email)
                 .or(User.where(phone_number: guest_phone_number))
                 .first

      return if user&.active_subscription&.present?

      temp_user = User.new(
        first_name: session_guest.first_name,
        last_name: session_guest.last_name,
        phone_number: guest_phone_number,
        email: guest_email
      )

      ActiveCampaignService.new(
        pipeline_name: ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).create_deal(
        ActiveCampaign::Deal::Event::CHECKED_IN_AS_GUEST_FOR_FIRST_TIME_NO_PURCHASE,
        temp_user
      )
    rescue ActiveCampaignException => e
      Rollbar.error(e)
    end
  end
end
