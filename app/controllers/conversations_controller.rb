class ConversationsController < ApplicationController
  before_action :set_print_job

  def show
    @conversation = @print_job.conversation
    @message      = @conversation.messages.build
  end

  private

  def set_print_job
    @print_job = PrintJob.find(params[:print_job_id])
  end
end
