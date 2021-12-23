module Api
  module V1
    module Sessions
      class UserSessionsController < Api::V1::ApiUserController
        def index
          @user_sessions =
            Session.find(params[:session_id])
                   .user_sessions
                   .where(date: date, checked_in: true)
                   .includes(:user, user: :image_attachment).order(:created_at)
        end

        def create
          user_session =
            ActiveRecord::Base.transaction do
              referral = User.find_by(referral_code: params[:referral_code])

              user_session = UserSession.new(
                session_id: params[:session_id],
                user_id: current_user_id,
                date: params[:date],
                referral: referral
              )

              if user_session.valid?
                user_session = UserSessionReferralCredits.new(user_session) if referral
                user_session = before_save_actions(user_session)
              end

              user_session.save!
              user_session
            end

          user_session_id = user_session.id
          CreateActiveCampaignDealJob.perform_later(
            ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
            current_user_id,
            user_session_id: user_session_id
          )
          SessionMailer.with(user_session_id: user_session_id).session_booked.deliver_later
        end

        private

        def before_save_actions(user_session)
          user_session = UserSessionSlackNotification.new(user_session)
          user_session = UserSessionAutoConfirmed.new(user_session)
          user_session = UserSessionConsumeCredit.new(user_session)
          user_session = UserSessionWithValidDate.new(user_session)
          UserSessionNotFull.new(user_session)
        end

        def date
          date = params[:date]
          return Time.zone.today unless date

          Date.strptime(date, '%m/%d/%Y')
        end

        def current_user_id
          current_user.id
        end
      end
    end
  end
end
