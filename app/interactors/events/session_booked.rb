module Events
  class SessionBooked
    include Interactor

    def call
      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
        context.user.id,
        user_session_id: context.user_session.id
      )
    end
  end
end
