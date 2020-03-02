task cancel_unconfirmed_sessions: :environment do
  klaviyo_service = KlaviyoService.new
  UnconfirmedSessionsQuery.new.ready_to_cancel.find_each do |user_session|
    user_session.canceled!
    klaviyo_service.event(Event::SESSION_FORFEITED, user_session.user)
  end
end
