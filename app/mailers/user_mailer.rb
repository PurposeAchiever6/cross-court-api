class UserMailer < ApplicationMailer
  def update_request
    @user_request_update = UserUpdateRequest.find(params[:user_update_request_id])

    mail(
      to: ENV['CC_TEAM_EMAIL'],
      subject: I18n.t('mailer.user.update_request', name: @user_request_update.user.full_name)
    )
  end
end