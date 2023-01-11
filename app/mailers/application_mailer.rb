class ApplicationMailer < ActionMailer::Base
  default from: "Crosscourt <#{ENV.fetch('CC_TEAM_EMAIL', nil)}>"
  layout 'mailer'
end
