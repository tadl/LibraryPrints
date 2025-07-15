class PatronMailer < ApplicationMailer
  MAIL_DOMAIN = ENV.fetch("MAILGUN_DOMAIN")

  default from:     "make@#{MAIL_DOMAIN}"
  default reply_to: "make@#{MAIL_DOMAIN}"

  def access_link(patron)
    @patron = patron
    @url = Rails.application.routes.url_helpers.dashboard_url(token: patron.access_token)

    mail to: @patron.email, subject: "Your 3D Print Job Portal Link"
  end
end
