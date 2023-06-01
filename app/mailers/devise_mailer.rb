class DeviseMailer < Devise::Mailer
  default from: 'Crosscourt <no-reply@cross-court.com>'

  default template_path: 'devise/mailer'
end
