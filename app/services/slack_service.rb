class SlackService
  attr_reader :notifier, :user, :date, :time, :location

  def initialize(user, date = nil, time = nil, location = nil)
    @notifier = Slack::Notifier.new(
      ENV.fetch('SLACK_WEBHOOK_URL', nil),
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

  def session_canceled
    notify_booking('notifier.slack.session_canceled')
  end

  def session_canceled_in_time
    notify_booking('notifier.slack.session_canceled_in_time')
  end

  def session_canceled_out_of_time
    notify_booking('notifier.slack.session_canceled_out_of_time')
  end

  def no_show
    notify_booking('notifier.slack.no_show')
  end

  def session_confirmed
    notify_booking('notifier.slack.session_confirmed')
  end

  def session_waitlist_confirmed
    notify_booking('notifier.slack.session_waitlist_confirmed')
  end

  def inactive_user
    notify_inactive('notifier.slack.inactive_user')
  end

  def inactive_first_timer_user(options = {})
    notify_inactive('notifier.slack.inactive_first_timer_user', options)
  end

  def member_with_credits_left(options = {})
    notify_inactive('notifier.slack.member_with_credits_left', options)
  end

  def season_pass_purchased(product)
    notify_product('notifier.slack.season_pass_purchased', product)
  end

  def subscription_canceled(subscription)
    notify_subscription('notifier.slack.subscription_canceled', subscription)
  end

  def subscription_scheduled_cancellation(subscription)
    notify_subscription('notifier.slack.subscription_scheduled_cancellation', subscription)
  end

  def subscription_updated(subscription, old_product)
    notify_subscription(
      'notifier.slack.subscription_updated',
      subscription,
      old_subscription_name: old_product.name
    )
  end

  def subscription_reactivated(subscription)
    notify_subscription('notifier.slack.subscription_reactivated', subscription)
  end

  def subscription_scheduled_cancellation_removed(subscription)
    notify_subscription('notifier.slack.subscription_scheduled_cancellation_removed', subscription)
  end

  def subscription_cancellation_request(subscription_cancellation_request)
    notify_subscription_cancellation_request(
      'notifier.slack.subscription_cancellation_request_created',
      subscription_cancellation_request
    )
  end

  def subscription_paused_for_next_period(subscription, options)
    notify_subscription('notifier.slack.subscription_paused_for_next_period', subscription, options)
  end

  def subscription_paused(subscription, options)
    notify_subscription('notifier.slack.subscription_paused', subscription, options)
  end

  def subscription_unpaused(subscription)
    notify_subscription('notifier.slack.subscription_unpaused', subscription)
  end

  def subscription_pause_canceled(subscription)
    notify_subscription('notifier.slack.subscription_pause_canceled', subscription)
  end

  def charge_error(description, error_message)
    notify_charge_error('notifier.slack.charge_error', description, error_message)
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
      channel: ENV.fetch('SLACK_CHANNEL_BOOKING', nil)
    )
  end

  def notify_inactive(i18n_message, options = {})
    options = {
      name: user.full_name,
      phone: user.phone_number,
      email: user.email
    }.merge(options)

    notify(I18n.t(i18n_message, **options), channel: ENV.fetch('SLACK_CHANNEL_CHURN', nil))
  end

  def notify_product(i18n_message, product, options = {})
    options = {
      name: user.full_name,
      phone: user.phone_number,
      product_name: product.name
    }.merge(options)

    notify(I18n.t(i18n_message, **options), channel: ENV.fetch('SLACK_CHANNEL_PRODUCTS', nil))
  end

  def notify_subscription(i18n_message, subscription, options = {})
    options = {
      name: user.full_name,
      phone: user.phone_number,
      subscription_name: subscription.name
    }.merge(options)

    notify(I18n.t(i18n_message, **options), channel: ENV.fetch('SLACK_CHANNEL_SUBSCRIPTIONS', nil))
  end

  def notify_subscription_cancellation_request(i18n_message, subscription_cancellation_request)
    notify(
      I18n.t(
        i18n_message,
        name: user.full_name,
        subscription_cancellation_request_url: subscription_cancellation_request.url
      ),
      channel: ENV.fetch('SLACK_CHANNEL_SUBSCRIPTIONS', nil)
    )
  end

  def notify_charge_error(i18n_message, description, error_message)
    notify(
      I18n.t(
        i18n_message,
        name: user.full_name, description:, error_message:
      ),
      channel: ENV.fetch('SLACK_CHANNEL_CHARGE_ERROR', nil)
    )
  end

  def notify(msg, options = {})
    notifier.ping(msg, options)
  rescue Slack::Notifier::APIError => e
    Rails.logger.error e
  end
end
