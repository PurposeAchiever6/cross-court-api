module Users
  class GiveFreeCredit
    include Interactor

    def call
      user = context.user

      if user.give_free_session?
        user.free_session_state = :not_claimed
        user.free_session_expiration_date = Time.zone.today + User::FREE_SESSION_EXPIRATION_DAYS
        user.increment(:credits)
        user.save!

        ::ActiveCampaign::CreateDealJob.perform_later(
          ::ActiveCampaign::Deal::Event::FIRST_FREE_CREDIT_ADDED,
          user.id
        )
      else
        user.update!(free_session_state: :not_apply, free_session_expiration_date: nil)
      end
    end
  end
end
