class JobMailer < ApplicationMailer
  def notify_patron
    @message = params[:message]
    @job = @message.conversation.job
    mail(
      to: @job.patron.email,
      subject: "New message about your print job ##{@job.id}"
    )
  end
end
