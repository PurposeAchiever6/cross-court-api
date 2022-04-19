class ApplicationMailer < ActionMailer::Base
  default from: "Crosscourt <#{ENV['CC_TEAM_EMAIL']}>"
  layout 'mailer'
end
