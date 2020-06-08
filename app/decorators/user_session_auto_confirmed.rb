class UserSessionAutoConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    unless user_session.in_cancellation_time?
      user_session.state = :confirmed
      SonarService.send_message(user, I18n.t('notifier.ultimatum', name: user.first_name))
    end
    user_session.save!
  end
end
