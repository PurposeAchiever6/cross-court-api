class SessionDecorator < Draper::Decorator
  delegate_all

  def title(date)
    text = time.utc.strftime(Session::TIME_FORMAT)

    return text += ' - (OC)' if open_club?

    return text += ' - (CS)' if coming_soon?

    text += " - #{reservations_count(date)}/#{max_capacity}"

    text += " W/#{waitlist_count(date)}"

    text += ' (P)' if is_private?

    text += ' (WO)' if women_only?

    text += ' (SS)' if skill_session?

    text += ' (AS)' if all_skill_levels_allowed

    text += ' (EM)' if referee(date).blank? || sem(date).blank?

    text
  end
end
