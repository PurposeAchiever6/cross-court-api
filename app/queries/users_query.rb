class UsersQuery
  attr_reader :relation

  def initialize(relation = User.all)
    @relation = relation
  end

  def expired_free_session_users
    relation.where(free_session_state: 0).where('free_session_expiration_date < ?', Time.zone.today)
  end
end
