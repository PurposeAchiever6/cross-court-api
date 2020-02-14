class UserSessionNotFull
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    raise FullSessionException, I18n.t('api.errors.session.full') if session.full?(date)

    user_session.save!
  end
end
