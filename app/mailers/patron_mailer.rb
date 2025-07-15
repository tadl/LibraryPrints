class PatronMailer < ApplicationMailer
  def access_link(patron)
    @patron = patron
    @url    = root_url(token: patron.access_token)
    mail to: @patron.email, subject: "Your 3D Print Job Portal Link"
  end
end
