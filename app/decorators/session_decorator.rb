class SessionDecorator < Draper::Decorator
  delegate_all

  def title(date)
    text = time.strftime(Session::TIME_FORMAT)
    text += ' (EM)' unless referee(date).present? && sem(date).present?
    text
  end

  def past?(date = nil)
    current_time = Time.zone.local_to_utc(Time.current.in_time_zone(time_zone))
    date = start_time if date.blank?
    session_time = "#{date} #{time}".to_datetime
    current_time > session_time
  end
end
