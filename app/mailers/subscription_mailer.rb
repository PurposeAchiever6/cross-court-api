class SubscriptionMailer < ApplicationMailer
  def feedback
    @user = User.find(params[:user_id])
    @feedback = params[:feedback]

    mail(to: ENV['CC_TEAM_EMAIL'], subject: I18n.t('mailer.subscription.feedback'))
  end
end
