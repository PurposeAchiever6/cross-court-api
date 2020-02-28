task ultimatum_session_reminders: :environment do
  UltimatumReadyQuery.new.confirmation_pending.find_each do |user_session|
    KlaviyoService.new.event(
      Event::SESSION_ULTIMATUM,
      user_session.user,
      user_session: user_session
    )
  end
end
