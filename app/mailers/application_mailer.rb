class ApplicationMailer < ActionMailer::Base
  default from: "Crosscourt <#{ENV.fetch('CC_TEAM_EMAIL', nil)}>"
  default 'Message-ID' => -> { "<#{SecureRandom.uuid}@#{ENV.fetch('SERVER_URL', nil)}>" }

  layout 'mailer'

  helper do
    def button_classes
      'background-color: #9999ff; text-decoration: none; font-size: 16px; ' \
        "font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-weight: 700; " \
        'color: #000000; padding: 10px 25px; box-shadow: 0px 4px 16px rgba(0, 0, 0, 0.25); ' \
        'display: inline-block'
    end
  end
end
