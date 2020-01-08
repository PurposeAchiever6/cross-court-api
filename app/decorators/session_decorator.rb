class SessionDecorator < Draper::Decorator
  delegate_all

  def title(date)
    text = time.strftime(Session::TIME_FORMAT)
    text += ' (EM)' unless referee(date).present? && sem(date).present?
    text
  end

  def full?(date)
    date.present? && user_sessions.reserved.by_date(date).count == Session::MAX_CAPACITY
  end
end
