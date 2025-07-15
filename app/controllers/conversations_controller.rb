class ConversationsController < ApplicationController
  before_action :set_print_job
  #before_action :authorize_staff!, only: :show

  def show
    @conversation = @print_job.conversation

    @conversation.messages.unread.find_each do |msg|
      msg.mark_read!
    end
    @message      = @conversation.messages.build
  end

  private

  def set_print_job
    @print_job = PrintJob.find(params[:print_job_id])
  end

  #def authorize_staff!
  #  head :forbidden unless current_staff_user
  #end
end
