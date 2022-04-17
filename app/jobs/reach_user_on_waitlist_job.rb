class ReachUserOnWaitlistJob < ApplicationJob
  queue_as :default

  def perform(session_id, date)
    session = Session.find(session_id)

    return if session.full?(date)

    current_time = Time.zone.local_to_utc(Time.current.in_time_zone(session.time_zone))
    session_time = "#{date} #{session.time}".to_datetime

    return if current_time > session_time - UserSessionWaitlist::MINUTES_TOLERANCE

    waitlist_item = session.waitlist(date).not_reached.includes(:user).find do |current|
      current_user = current.user
      current_user.credits? && !session.full?(date, current_user)
    end

    return unless waitlist_item

    UserSessions::Create.call(
      session: session,
      user: waitlist_item.user,
      date: date,
      from_waitlist: true
    )

    waitlist_item.update!(reached: true)
  end
end
