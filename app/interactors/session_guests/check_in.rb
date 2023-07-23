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
    end
  end
end
