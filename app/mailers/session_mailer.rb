class SessionMailer < ApplicationMailer
  def session_booked
    @user_session = UserSession.find(params[:user_session_id])
    event = @user_session.create_ics_event
    @session = @user_session.session
    @location = @session.location
    @user = @user_session.user
    attachments[I18n.t('mailer.session.add_to_calendar')] = {
      mime_type: 'text/calendar',
      content: event.export
    }
    mail(to: @user_session.user_email, subject: I18n.t('mailer.session.booked'))
  end

  def guest_session_booked
    @session_guest = SessionGuest.find(params[:session_guest_id])
    @user_session = @session_guest.user_session
    event = @user_session.create_ics_event
    @session = @user_session.session
    @location = @session.location
    @user = User.new(
      first_name: @session_guest.first_name,
      last_name: @session_guest.last_name,
      email: @session_guest.email
    )
    attachments[I18n.t('mailer.session.add_to_calendar')] = {
      mime_type: 'text/calendar',
      content: event.export
    }
    mail(to: @user.email, subject: I18n.t('mailer.session.booked'))
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

  def no_charge_session
    @session = Session.find(params[:session_id])
    @user = User.find(params[:user_id])
    @date = params[:date]

    mail(to: @user.email, subject: I18n.t('mailer.session.no_charge_session.subject'))
  end
end
