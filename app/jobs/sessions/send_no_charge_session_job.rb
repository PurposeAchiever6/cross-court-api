module Sessions
  class SendNoChargeSessionJob < ApplicationJob
    queue_as :default

    def perform
      products_with_no_booking_charge_feature = Product.no_booking_charge_feature

      Location.find_each do |location|
        date = Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)).to_date

        products_with_no_booking_charge_feature.each do |product|
          sessions = location.sessions
                             .includes(:session_exceptions)
                             .eligible_for_free_booking
                             .for_range(date, date)
                             .in_hours(product.no_booking_charge_feature_hours)
                             .flat_map { |session| session.calendar_events(date, date) }

          sessions.each do |session|
            next if session.reservations_count(date) > Session::RESERVATIONS_LIMIT_FOR_NO_CHARGE

            auto_enable_guests(session) if session.allow_auto_enable_guests?

            User.joins(active_subscription: :product)
                .where(subscriptions: { status: :active })
                .where(products: { id: product.id })
                .find_each do |user|
              next if user.not_canceled_user_session?(session, date)

              SessionMailer.with(
                session_id: session.id,
                user_id: user.id,
                date:
              ).no_charge_session.deliver_later
            end
          end
        end
      end
    end

    def auto_enable_guests(session)
      guests_allowed = ENV.fetch('AUTO_ENABLE_GUESTS_ALLOWED', '5').to_i
      guests_allowed_per_user = ENV.fetch('AUTO_ENABLE_GUESTS_ALLOWED_PER_USER', '1').to_i

      session.guests_allowed = guests_allowed if (session.guests_allowed || 0) < guests_allowed

      if (session.guests_allowed_per_user || 0) < guests_allowed_per_user
        session.guests_allowed_per_user = guests_allowed_per_user
      end

      session.save! if session.changed?
    end
  end
end
