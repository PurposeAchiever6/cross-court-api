module UserSessions
  class ReferralCredits
    include Interactor

    def call
      referral = context.referral

      return unless referral

      user_session = context.user_session
      user = user_session.user
      referral = user_session.referral
      user_id = user.id
      referral_id = referral.id

      return unless referral_id != user_id && user.user_sessions.count == 1

      referral.increment(:credits)
      referral.save!
      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS,
        referral_id,
        referred_id: user_id
      )
    end
  end
end
