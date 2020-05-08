class SlackService
  attr_reader :notifier
  def initialize
    @notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'], channel: ENV['SLACK_CHANNEL'],
                                                              username: 'Notifier')
  end

  def session_booked(user, date, time, location)
    notifier.ping(
      I18n.t('notifier.session_booked', name: user.decorate.full_name,
                                        date: date.strftime(Session::DATE_FORMAT),
                                        time: time.strftime(Session::TIME_FORMAT),
                                        location: location.name)
    )
  rescue Slack::Notifier::APIError => e
    Rails.logger.error e
  end
end
