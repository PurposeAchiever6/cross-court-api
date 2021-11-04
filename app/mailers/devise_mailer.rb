class DeviseMailer < Devise::Mailer
  default 'Message-ID' => -> { "<#{SecureRandom.uuid}@#{ENV['SERVER_URL']}>" }
end
