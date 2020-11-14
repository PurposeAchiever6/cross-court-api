class UsersQuery
  attr_reader :relation

  def initialize(relation = User.all)
    @relation = relation
  end

  def expired_free_session_users
    relation.where(free_session_state: :not_claimed)
            .where('free_session_expiration_date < ?', Time.zone.today)
  end

  def free_session_not_used_in(in_time)
    free_session_expiration_date = ((User::FREE_SESSION_EXPIRATION_DAYS - in_time) / 1.day).days
                                                                                           .from_now
                                                                                           .to_date

    relation.where(free_session_state: :not_claimed)
            .where(free_session_expiration_date: free_session_expiration_date)
  end

  def free_session_expires_in(in_time)
    relation.where(free_session_state: :not_claimed)
            .where(free_session_expiration_date: Time.zone.today + in_time)
  end
end
