class UserSessionSlackNotification
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'], channel: ENV['SLACK_CHANNEL'],
                                                             username: 'Notifier'
    notifier.ping I18n.t('notifier.session_booked', date: date.strftime(Session::DATE_FORMAT),
                                                    time: time.strftime(Session::TIME_FORMAT),)
  end
end
