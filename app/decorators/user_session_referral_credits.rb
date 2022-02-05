class UserSessionReferralCredits
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    referral_id = referral.id

    if referral_id != user_id && user.user_sessions.count == 1
      referral.increment(:credits)
      referral.save!
      CreateActiveCampaignDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS,
        referral_id,
        referred_id: user.id
      )
    end

    user_session.save!
  end
end
