class UserSessionAutoConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    unless user_session.in_cancellation_time?
      user_session.state = :confirmed

      ultimatum_msg = I18n.t('notifier.ultimatum', name: user.first_name)
      app_instructions_msg = I18n.t(
        'notifier.app_instructions',
        app_link: "#{ENV['FRONTENT_URL']}/app"
      )

      message = if user_session.is_free_session
                  "#{ultimatum_msg} #{app_instructions_msg}"
                else
                  ultimatum_msg
                end

      SonarService.send_message(user, message)
    end
    user_session.save!
  end
end
