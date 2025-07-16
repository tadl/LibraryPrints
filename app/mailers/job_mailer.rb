# app/mailers/job_mailer.rb
class JobMailer < ApplicationMailer
  MAIL_DOMAIN = ENV.fetch("MAILGUN_DOMAIN")

  def notify_patron(message)
    @message      = message
    @conversation = message.conversation
    @job          = @conversation.job
    @patron       = @job.patron

    @url = job_url(@job, token: @patron.access_token)

    # use the conversation’s conversation_token for plus‐addressing
    reply_address = "TADL Makerspace <make+#{@conversation.conversation_token}@make.tadl.org>"

    job_label = @job.is_a?(PrintJob) ? "print" : "scan"

    mail to:      @patron.email,
         from:    reply_address,
         reply_to: reply_address,
         subject: "New message on your #{job_label} job ##{@job.id}"
  end
end
