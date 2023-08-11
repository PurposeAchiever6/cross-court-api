module SessionGuests
  class CheckIn
    include Interactor

    def call
      session_guest = context.session_guest
      checked_in = context.checked_in
      assigned_team = context.assigned_team

      session_guest.update!(
        checked_in:,
        assigned_team:
      )

      return unless session_guest.first_time?

      ::ActiveCampaign::NoPurchasePlacedAfterGuestCheckInJob.set(wait: 24.hours)
                                                            .perform_later(session_guest.id)
    end
  end
end
