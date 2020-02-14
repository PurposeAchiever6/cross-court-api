class FreeSessionsQuery
  attr_reader :relation

  def initialize(relation = UserSession.all)
    @relation = relation.for_yesterday
  end

  def chargeable
    relation.where(is_free_session: true, checked_in: false)
  end
end
