module Sessions
  class ReachUserOnWaitlistJob < ApplicationJob
    queue_as :default

    def perform(session_id, date)
      session = Session.find(session_id)

      return if session.full?(date)

      current_time = Time.zone.local_to_utc(Time.current.in_time_zone(session.time_zone))
      session_time = "#{date} #{session.time}".to_datetime

      return if current_time > session_time - UserSessionWaitlist::MINUTES_TOLERANCE

      skill_session = session.skill_session?

      waitlist_item = session.waitlist(date).pending.includes(:user).find do |current|
        current_user = current.user

        next if session.full?(date, current_user)

        skill_session ? current_user.skill_session_credits? : current_user.credits?
      end

      return unless waitlist_item

      UserSessions::Create.call(
        session: session,
        user: waitlist_item.user,
        date: date,
        from_waitlist: true
      )

      waitlist_item.update!(state: :success)
    end
  end
end
