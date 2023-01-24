class SubscriptionMailer < ApplicationMailer
  def cancellation_request
    @user = User.find(params[:user_id])
    @reason = params[:reason]

    mail(to: ENV.fetch('CC_TEAM_EMAIL', nil),
         subject: I18n.t('mailer.subscription.cancellation_request'))
  end
end
