class UserSessionAutoConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    unless user_session.in_cancellation_time?
      user_session.state = :confirmed

      unless user_session.reminder_sent_at
        SonarService.send_message(user, message)
        user_session.reminder_sent_at = Time.zone.now
      end

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
        user.id,
        user_session_id: user_session.id
      )

      SlackService.new(user, date, time, location).session_auto_confirmed
    end

    user_session.save!
  end

  private

  def invite_friend
    return '' if session.full?(date)

    I18n.t('notifier.sonar.invite_friend', link: invite_link)
  end

  def message
    name = user.first_name
    time = user_session.time.strftime(Session::TIME_FORMAT)

    I18n.t('notifier.sonar.session_auto_confirmed',
           name: name,
           time: time,
           location: location.name,
           frontend_url: ENV['FRONTENT_URL'],
           invite_friend: invite_friend)
  end
end
