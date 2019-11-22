class SessionMailer < ApplicationMailer
  HOUR_FORMAT = '%H:%M'.freeze

  def new_session(user, time, date, user_session_id)
    @user_name = user.name
    @date = date
    @time = time
    @user_session_id = user_session_id
    mail(
      to: user.email,
      subject: t('mailer.session.new.subject')
    )
  end
end
