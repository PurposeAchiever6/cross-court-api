class DeviseMailer < Devise::Mailer
  default 'Message-ID' => -> { "<#{SecureRandom.uuid}@#{ENV['SERVER_URL']}>" }
  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, options = {})
    options[:template_name] =
      if record.confirmation_sent_at <= Date.yesterday
        're_confirmation_instructions'
      else
        'confirmation_instructions'
      end

    super
  end
end
