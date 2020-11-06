class UsersQuery
  attr_reader :relation

  def initialize(relation = User.all)
    @relation = relation
  end

  def expired_free_session_users
    relation.where(free_session_state: :not_claimed).where('free_session_expiration_date < ?', Time.zone.today)
  end

  def free_session_not_used_in_7_days
    relation.where(free_session_state: :not_claimed).where(free_session_expiration_date: 23.days.from_now.to_date)
  end
end
