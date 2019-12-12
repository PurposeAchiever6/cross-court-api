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

  def reminder(email, user_name, session_id, date)
    @user_name = user_name
    formatted_date = date.strftime(Session::DATE_FORMAT)
    @confirmation_url = "#{ENV['FRONTENT_URL']}/sessions/#{session_id}?date=#{formatted_date}"
    mail(
      to: email,
      subject: t('mailer.session.reminder.subject')
    )
  end
end
