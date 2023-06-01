class SessionDecorator < Draper::Decorator
  delegate_all

  def title(date)
    text = time.utc.strftime(Session::TIME_FORMAT)

    return text += ' - (CS)' if coming_soon?

    text += " - #{reservations_count(date)}#{max_capacity ? "/#{max_capacity}" : ''}"

    return text += ' - (OH)' if open_club?

    text += " W/#{waitlist_count(date)}"

    text += ' (P)' if is_private?

    text += ' (WO)' if women_only?

    text += ' (SS)' if skill_session?

    text += ' (AS)' if all_skill_levels_allowed

    if (normal_session? && (referee(date).blank? || sem(date).blank?)) ||
       (skill_session? && coach(date).blank?)
      text += ' (EM)'
    end

    text
  end
end
