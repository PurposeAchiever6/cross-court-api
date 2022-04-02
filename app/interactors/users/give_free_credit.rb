module Users
  class GiveFreeCredit
    include Interactor

    def call
      user = context.user

      return unless user.free_session_not_claimed? && !user.free_session_expiration_date?

      user.free_session_expiration_date = Time.zone.today + User::FREE_SESSION_EXPIRATION_DAYS
      user.increment(:credits)
      user.save!

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::FIRST_FREE_CREDIT_ADDED,
        user.id
      )
    end
  end
end
