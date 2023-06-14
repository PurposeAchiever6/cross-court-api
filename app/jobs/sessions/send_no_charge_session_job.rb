module Sessions
  class SendNoChargeSessionJob < ApplicationJob
    queue_as :default

    def perform
      cancellation_period_hours = Session::CANCELLATION_PERIOD.to_i / 3600

      Location.find_each do |location|
        date = Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)).to_date
        sessions = location.sessions
                           .includes(:session_exceptions)
                           .for_range(date, date)
                           .in_hours(cancellation_period_hours)
                           .flat_map { |session| session.calendar_events(date, date) }

        sessions.each do |session|
          next if session.reservations_count(date) > Session::RESERVATIONS_LIMIT_FOR_NO_CHARGE

          User.joins(active_subscription: :product)
              .where(subscriptions: { status: :active })
              .where(products: { no_booking_charge_after_cancellation_window: true })
              .find_each do |user|
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
end
