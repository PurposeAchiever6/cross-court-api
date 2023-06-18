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
                             .for_range(date, date)
                             .in_hours(product.no_booking_charge_feature_hours)
                             .normal_sessions
                             .flat_map { |session| session.calendar_events(date, date) }

          sessions.each do |session|
            next if session.reservations_count(date) > Session::RESERVATIONS_LIMIT_FOR_NO_CHARGE

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
  end
end
