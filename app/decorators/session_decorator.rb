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
end
