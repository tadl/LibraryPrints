class PrintJobMailer < ApplicationMailer
  def notify_patron
    @message = params[:message]
    @print_job = @message.conversation.print_job
    mail(
      to: @print_job.patron.email,
      subject: "New message about your print job ##{@print_job.id}"
    )
  end
end
