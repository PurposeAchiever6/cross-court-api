task charge_free_session_players: :environment do
  FreeSessionQuery.new.chargeable.find_each do |user_session|
    StripeService.confirm_intent(user_session.free_session_payment_intent)
    user_session.update!(is_free_session: false)
  end
end
