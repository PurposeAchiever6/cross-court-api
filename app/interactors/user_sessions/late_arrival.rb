module UserSessions
  class LateArrival
    include Interactor

    def call
      user_session = context.user_session
      checked_in_time = context.checked_in_time
      user = user_session.user

      allowed_late_arrivals = user_session.location_allowed_late_arrivals
      late_arrival_fee = user_session.location_late_arrival_fee
      late_arrival_minutes = user_session.location_late_arrival_minutes

      return unless run_late_arrival_logic?(user_session, checked_in_time)

      if user.late_arrivals.count >= allowed_late_arrivals
        Users::Charge.call(
          user:,
          amount: late_arrival_fee,
          description: 'Session late arrival fee',
          notify_error: true,
          use_cc_cash: true,
          create_payment_on_failure: true
        )
      else
        SonarService.send_message(
          user,
          I18n.t(
            'notifier.sonar.late_arrival_warning',
            name: user.first_name,
            late_arrival_minutes:,
            allowed_late_arrivals:,
            penalized_late_arrivals: (allowed_late_arrivals + 1).ordinalize,
            late_arrival_fee:
          )
        )
      end

      ::LateArrival.create!(user:, user_session:)
    end

    private

    def run_late_arrival_logic?(user_session, checked_in_time)
      session = user_session.session

      !session.open_club? && \
        user_session.late_arrival?(checked_in_time) \
          && user_session.location_late_arrival_fee.positive? \
            && user_session.late_arrival.blank?
    end
  end
end
