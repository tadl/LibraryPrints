class ApplicationMailer < ActionMailer::Base
  default from:     "make@make.tadl.org"
  default reply_to: "make@make.tadl.org"
  layout "mailer"

  private

  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end
end
