class EmployeeSessionConfirmed
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def save!
    referee_session = user.referee_sessions.future.unconfirmed.ordered_by_date.first
    sem_session = user.sem_sessions.future.unconfirmed.ordered_by_date.first

    is_sem = user.is_sem?
    is_referee = user.is_referee?

    if is_referee && is_sem && referee_session && sem_session
      confirm_first_session(referee_session, sem_session)
    elsif is_referee && referee_session
      confirm_referee_session(referee_session)
    elsif is_sem && sem_session
      confirm_sem_session(sem_session)
    end
  end

  private

  def confirm_referee_session(referee_session)
    referee_session.state = :confirmed if referee_session.unconfirmed?
    KlaviyoService.new.event(Event::REFEREE_SESSION_CONFIRMATION, user, referee_session: referee_session)
    referee_session.save!
  end

  def confirm_sem_session(sem_session)
    sem_session.state = :confirmed if sem_session.unconfirmed?
    KlaviyoService.new.event(Event::SEM_SESSION_CONFIRMATION, user, sem_session: sem_session)
    sem_session.save!
  end

  def confirm_first_session(referee_session, sem_session)
    if referee_session.date < sem_session.date
      confirm_referee_session(referee_session)
    else
      confirm_sem_session(sem_session)
    end
  end
end
