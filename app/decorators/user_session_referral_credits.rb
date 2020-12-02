class UserSessionReferralCredits
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    if referral && referral.id != user_id && user.first_session?
      referral.increment(:credits)
      referral.save!
      KlaviyoService.new.event(Event::REFERRAL_SUCCESS, referral, referred: user)
    end

    user_session.save!
  end
end
