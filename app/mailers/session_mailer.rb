class SessionMailer < ApplicationMailer
  HOUR_FORMAT = '%H:%M'.freeze

  def new_session(user, session, date, user_session_id)
    @user_name = user.name
    @session_name = session.name
    @date = date
    @time = session.time
    @user_session_id = user_session_id
    mail(
      to: user.email,
      subject: t('mailer.session.new.subject')
    )
  end
end
