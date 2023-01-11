class SessionMailer < ApplicationMailer
  def session_booked
    @user_session = UserSession.find_by(id: params[:user_session_id])
    return unless @user_session

    event = @user_session.create_ics_event
    @location = @user_session.session.location
    @user = @user_session.user
    attachments[I18n.t('mailer.session.add_to_calendar')] = {
      mime_type: 'text/calendar',
      content: event.export
    }
    mail(to: @user_session.user_email, subject: I18n.t('mailer.session.booked'))
  end

  def checked_in_session_notice
    @user = User.find(params[:user_id])
    @number_of_sessions = params[:number_of_sessions]

    mail(
      to: [ENV.fetch('CC_TEAM_EMAIL', nil), ENV.fetch('CC_MKTG_EMAIL', nil)],
      subject: I18n.t('mailer.session.checked_in_session_notice',
                      number_of_sessions: @number_of_sessions)
    )
  end
end
