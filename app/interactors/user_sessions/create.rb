module UserSessions
  class Create
    include Interactor

    def call
      user = context.user
      session = context.session
      date = context.date
      referral_code = context.referral_code || nil
      not_charge_user_credit = context.not_charge_user_credit || false
      from_waitlist = context.from_waitlist || false

      raise SessionIsOpenClubException if session.open_club?
      raise FullSessionException if session.full?(date, user)

      user_session =
        ActiveRecord::Base.transaction do
          referral = User.find_by(referral_code: referral_code)

          user_session = UserSession.create!(
            session: session,
            user: user,
            date: date,
            referral: referral
          )

          user_session = UserSessionReferralCredits.new(user_session) if referral
          user_session = UserSessionAutoConfirmed.new(user_session) unless from_waitlist
          user_session = UserSessionWaitlistConfirmed.new(user_session) if from_waitlist
          user_session = UserSessionSlackNotification.new(user_session) unless from_waitlist
          user_session = UserSessionConsumeCredit.new(user_session, not_charge_user_credit)
          user_session = UserSessionWithValidDate.new(user_session)

          user_session.save!
          user_session
        end

      context.user_session = user_session

      user_session_id = user_session.id
      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
        user.id,
        user_session_id: user_session_id
      )

      SessionMailer.with(user_session_id: user_session_id).session_booked.deliver_later
    end
  end
end
