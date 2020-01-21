class RemoveOrphanSessions
  include Interactor

  def call
    session = context.session
    remove_orphan_sem_sessions(session)
    remove_orphan_referee_sessions(session)
    remove_orphan_user_sessions(session)
  end

  private

  def remove_orphan_sem_sessions(session)
    session.sem_sessions.future.find_each do |sem_session|
      next if session.schedule.occurs_on?(sem_session.date)

      sem_session.destroy!
    end
  end

  def remove_orphan_referee_sessions(session)
    session.referee_sessions.future.find_each do |referee_session|
      next if session.schedule.occurs_on?(referee_session.date)

      referee_session.destroy!
    end
  end

  def remove_orphan_user_sessions(session)
    session.user_sessions.future.includes(:user).find_each do |user_session|
      next if session.schedule.occurs_on?(user_session.date)

      user = user_session.user
      user.increment(:credits)
      user.save!
      user_session.destroy!
    end
  end
end
