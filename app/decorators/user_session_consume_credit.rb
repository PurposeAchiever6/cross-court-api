class UserSessionConsumeCredit
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    unless user.credits?
      raise NotEnoughCreditsException, I18n.t('api.errors.user_session.not_enough_credits')
    end

    if user.free_session_claimed?
      user_session.is_free_session = true
      user_session.free_session_payment_intent = user.free_session_payment_intent
      user.free_session_state = :used
    end

    if user.credits.positive?
      user.decrement(:credits)
    else
      user.decrement(:subscription_credits) unless user.unlimited_credits?
    end

    user.save!
    user_session.save!
  end
end
