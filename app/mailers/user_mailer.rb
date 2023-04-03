class UserMailer < ApplicationMailer
  def update_request
    @user_request_update = UserUpdateRequest.find(params[:user_update_request_id])

    mail(
      to: ENV.fetch('CC_TEAM_EMAIL', nil),
      subject: I18n.t('mailer.user.subjects.update_request',
                      name: @user_request_update.user.full_name)
    )
  end

  def membership_handbook
    user_email = params[:email]
    attachments['crosscourt-member-handbook.pdf'] = Rails.root.join(
      'app/assets/pdfs/crosscourt-member-handbook.pdf'
    ).read

    mail(
      to: user_email,
      subject: I18n.t('mailer.user.subjects.membership_handbook')
    )
  end
end
