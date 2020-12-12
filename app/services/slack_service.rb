class SlackService
  attr_reader :notifier, :user, :date, :time, :location

  def initialize(user, date = nil, time = nil, location = nil)
    @notifier = Slack::Notifier.new(
      ENV['SLACK_WEBHOOK_URL'],
      channel: ENV['SLACK_CHANNEL_DEFAULT'],
      username: 'Backend Notifier'
    )

    @user = user
    @date = date
    @time = time
    @location = location
  end

  def session_booked
    notify_booking('notifier.slack.session_booked')
  end

  def session_canceled_in_time
    notify_booking('notifier.slack.session_canceled_in_time')
  end

  def session_canceled_out_of_time
    notify_booking('notifier.slack.session_canceled_out_of_time')
  end

  def session_confirmed
    notify_booking('notifier.slack.session_confirmed')
  end

  def inactive_user
    notify(
      I18n.t('notifier.slack.inactive_user', name: user.full_name, phone: user.phone_number),
      channel: ENV['SLACK_CHANNEL_CHURN']
    )
  end

  private

  def notify_booking(i18n_message)
    notify(
      I18n.t(
        i18n_message,
        name: user.full_name,
        date: date.strftime(Session::DATE_FORMAT),
        time: time.strftime(Session::TIME_FORMAT),
        location: location.name
      ),
      channel: ENV['SLACK_CHANNEL_BOOKING']
    )
  end

  def notify(msg, options = {})
    notifier.ping(msg, options)
  rescue Slack::Notifier::APIError => e
    Rails.logger.error e
  end
end
