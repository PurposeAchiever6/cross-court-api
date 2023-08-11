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

      return unless SessionGuest.where(phone_number: session_guest.phone_number).count == 1

      ::ActiveCampaign::NoPurchasePlacedAfterGuestCheckInJob.set(wait: 24.hours)
                                                            .perform_later(session_guest.id)
    end
  end
end
