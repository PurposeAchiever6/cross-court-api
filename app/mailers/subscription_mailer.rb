class SubscriptionMailer < ApplicationMailer
  def cancellation_request
    @user = User.find(params[:user_id])
    @reason = params[:reason]

    mail(to: ENV['CC_TEAM_EMAIL'], subject: I18n.t('mailer.subscription.cancellation_request'))
  end
end
