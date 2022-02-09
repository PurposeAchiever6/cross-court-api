class SessionDecorator < Draper::Decorator
  delegate_all

  def title(date)
    text = time.utc.strftime(Session::TIME_FORMAT)

    text += if referee(date).present? && sem(date).present?
              " - #{reservations_count(date)}/#{Session::MAX_CAPACITY}"
            else
              ' (EM)'
            end

    text
  end

  def past?(date = nil)
    current_time = Time.zone.local_to_utc(Time.current.in_time_zone(time_zone))
    date = start_time if date.blank?
    session_time = "#{date} #{time}".to_datetime
    current_time > session_time
  end
end
