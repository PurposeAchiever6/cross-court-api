class UserSessionReferralCredits
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    if referral
      referral.increment(:credits)
      referral.save!
    end

    user_session.save!
  end
end
