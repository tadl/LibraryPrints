class MessagesController < ApplicationController
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(message_params)
    @message.author = current_staff_user  # or however you identify staff

    if @message.save
      redirect_to print_job_conversation_path(@conversation.print_job)
    else
      render 'conversations/show', status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
