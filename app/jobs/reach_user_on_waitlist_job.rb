class ReachUserOnWaitlistJob < ApplicationJob
  queue_as :default

  def perform(session_id, date)
    session = Session.find(session_id)

    return if session.full?(date)

    waitlist_item = session.waitlist(date).not_reached.includes(:user).find do |current|
      current.user.credits?
    end

    return unless waitlist_item

    UserSessions::CreateUserSession.call(
      session: session,
      user: waitlist_item.user,
      date: date,
      from_waitlist: true
    )

    waitlist_item.update!(reached: true)
  end
end
