module UserSessions
  class CreateUserSession
    include Interactor

    def call
      user_id = context.user_id
      session_id = context.session_id
      date = context.date
      referral_code = context.referral_code || nil
      not_charge_user_credit = context.not_charge_user_credit || false

      user_session =
        ActiveRecord::Base.transaction do
          referral = User.find_by(referral_code: referral_code)

          user_session = UserSession.create!(
            session_id: session_id,
            user_id: user_id,
            date: date,
            referral: referral
          )

          if user_session.valid?
            user_session = UserSessionReferralCredits.new(user_session) if referral
            user_session = UserSessionSlackNotification.new(user_session)
            user_session = UserSessionAutoConfirmed.new(user_session)
            user_session = UserSessionConsumeCredit.new(user_session) unless not_charge_user_credit
            user_session = UserSessionWithValidDate.new(user_session)
            user_session = UserSessionNotFull.new(user_session)
          end

          user_session.save!
          user_session
        end

      user_session_id = user_session.id
      CreateActiveCampaignDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
        user_id,
        user_session_id: user_session_id
      )
      SessionMailer.with(user_session_id: user_session_id).session_booked.deliver_later
    end
  end
end
