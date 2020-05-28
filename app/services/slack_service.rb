class SlackService
  attr_reader :notifier, :user, :date, :time, :location

  def initialize(user, date, time, location)
    @notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'], channel: ENV['SLACK_CHANNEL'],
                                                              username: 'Notifier')
    @user = user
    @date = date
    @time = time
    @location = location
  end

  def session_booked
    notify('notifier.slack.session_booked')
  end

  def session_canceled_in_time
    notify('notifier.slack.session_canceled_in_time')
  end

  def session_canceled_out_of_time
    notify('notifier.slack.session_canceled_out_of_time')
  end

  def session_confirmed
    notify('notifier.slack.session_confirmed')
  end

  private

  def notify(i18n_message)
    notifier.ping(I18n.t(i18n_message, name: user.decorate.full_name,
                                       date: date.strftime(Session::DATE_FORMAT),
                                       time: time.strftime(Session::TIME_FORMAT),
                                       location: location.name))
  rescue Slack::Notifier::APIError => e
    Rails.logger.error e
  end
end
