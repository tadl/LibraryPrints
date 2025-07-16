# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  MAIL_DOMAIN = ENV.fetch("MAILGUN_DOMAIN")

  default from:     "TADL Makerspace <make@#{MAIL_DOMAIN}>"
  default reply_to: "TADL Makerspace <make@#{MAIL_DOMAIN}>"
  layout "mailer"

  def self.default_url_options
    Rails.application.config.action_mailer.default_url_options
  end
end
