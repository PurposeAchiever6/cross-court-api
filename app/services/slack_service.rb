class SlackService
  attr_reader :notifier, :user, :date, :time, :location

  def initialize(user, date = nil, time = nil, location = nil)
    @notifier = Slack::Notifier.new(
      ENV['SLACK_WEBHOOK_URL'],
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

  def session_auto_confirmed
    notify_booking('notifier.slack.session_auto_confirmed')
  end

  def session_waitlist_confirmed
    notify_booking('notifier.slack.session_waitlist_confirmed')
  end

  def inactive_user
    notify_inactive('notifier.slack.inactive_user')
  end

  def inactive_first_timer_user
    notify_inactive('notifier.slack.inactive_first_timer_user')
  end

  def subscription_canceled(subscription)
    notify_subscription('notifier.slack.subscription_canceled', subscription)
  end

  def subscription_reactivated(subscription)
    notify_subscription('notifier.slack.subscription_reactivated', subscription)
  end

  def subscription_feedback(subscription_feedback)
    notify_subscription_feedback(
      'notifier.slack.subscription_feedback_created',
      subscription_feedback
    )
  end

  def charge_error(description, error_message)
    notify_charge_error('notifier.slack.charge_error', description, error_message)
  end

  private

  def notify_booking(i18n_message, extra_params = {})
    notify(
      I18n.t(
        i18n_message,
        {
          name: user.full_name,
          date: date.strftime(Session::DATE_FORMAT),
          time: time.strftime(Session::TIME_FORMAT),
          location: location.name
        }.merge(extra_params)
      ),
      channel: ENV['SLACK_CHANNEL_BOOKING']
    )
  end

  def notify_inactive(i18n_message)
    notify(
      I18n.t(
        i18n_message,
        name: user.full_name,
        phone: user.phone_number
      ),
      channel: ENV['SLACK_CHANNEL_CHURN']
    )
  end

  def notify_subscription(i18n_message, subscription)
    notify(
      I18n.t(
        i18n_message,
        name: user.full_name,
        phone: user.phone_number,
        subscription_name: subscription.name
      ),
      channel: ENV['SLACK_CHANNEL_SUBSCRIPTIONS']
    )
  end

  def notify_subscription_feedback(i18n_message, subscription_feedback)
    notify(
      I18n.t(
        i18n_message,
        name: user.full_name,
        subscription_feedback_url: subscription_feedback.url
      ),
      channel: ENV['SLACK_CHANNEL_SUBSCRIPTIONS']
    )
  end

  def notify_charge_error(i18n_message, description, error_message)
    notify(
      I18n.t(
        i18n_message,
        name: user.full_name,
        description: description,
        error_message: error_message
      ),
      channel: ENV['SLACK_CHANNEL_CHARGE_ERROR']
    )
  end

  def notify(msg, options = {})
    notifier.ping(msg, options)
  rescue Slack::Notifier::APIError => e
    Rails.logger.error e
  end
end
