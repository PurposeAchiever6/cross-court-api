class SubscriptionMailer < ApplicationMailer
  def feedback
    @user = User.find(params[:user_id])
    @feedback = params[:feedback]

    mail(to: @user.email, subject: I18n.t('mailer.subscription.feedback'))
  end
end
