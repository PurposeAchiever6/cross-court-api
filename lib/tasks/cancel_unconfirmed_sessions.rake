task cancel_unconfirmed_sessions: :environment do
  UnconfirmedSessionsQuery.new.ready_to_cancel.update_all(state: :canceled)
end
