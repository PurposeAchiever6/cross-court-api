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
end
