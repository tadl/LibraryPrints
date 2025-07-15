# app/mailers/job_mailer.rb
class JobMailer < ApplicationMailer
  def notify_patron(message)
    @message      = message
    @conversation = message.conversation
    @job          = @conversation.job
    @patron       = @job.patron

    # build patron‐facing link
    @url = job_url(@job, token: @patron.access_token)

    # use the conversation’s conversation_token for plus‐addressing
    reply_address = "make+#{@conversation.conversation_token}@make.tadl.org"

    mail to:      @patron.email,
         from:    reply_address,
         reply_to: reply_address,
         subject: "New message on your print job ##{@job.id}"
  end
end
