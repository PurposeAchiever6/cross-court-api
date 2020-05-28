class SlackService
  attr_reader :notifier
  def initialize
    @notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'], channel: ENV['SLACK_CHANNEL'],
                                                              username: 'Notifier')
  end

  def session_booked(user, date, time, location)
    notify(I18n.t('notifier.slack.session_booked', name: user.decorate.full_name,
                                                   date: date.strftime(Session::DATE_FORMAT),
                                                   time: time.strftime(Session::TIME_FORMAT),
                                                   location: location.name))
  end

  def session_canceled_in_time(user, date, time, location)
    notify(I18n.t('notifier.slack.session_canceled_in_time',
                  name: user.decorate.full_name,
                  date: date.strftime(Session::DATE_FORMAT),
                  time: time.strftime(Session::TIME_FORMAT),
                  location: location.name))
  end

  def session_canceled_out_of_time(user, date, time, location)
    notify(I18n.t('notifier.slack.session_canceled_out_of_time',
                  name: user.decorate.full_name,
                  date: date.strftime(Session::DATE_FORMAT),
                  time: time.strftime(Session::TIME_FORMAT),
                  location: location.name))
  end

  private

  def notify(message)
    notifier.ping(message)
  rescue Slack::Notifier::APIError => e
    Rails.logger.error e
  end
end
