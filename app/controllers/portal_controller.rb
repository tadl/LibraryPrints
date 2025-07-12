# app/controllers/portal_controller.rb
class PortalController < ApplicationController
  layout 'application'

  # Patron must be loaded for dashboard, show, and create_message
  before_action :load_patron, only: %i[dashboard show create_message]
  # Print job must be loaded for show and create_message
  before_action :load_print_job, only: %i[show create_message]

  # Public landing page with info and a link to the submission form
  def home
  end

  # Display the 3D print submission form
  def submit
    @print_job = PrintJob.new
  end

  # Handle print job submission from public form
  def create_job
    p = params.require(:patron).permit(:first_name, :last_name, :email)
    @patron = Patron.find_or_initialize_by(email: p[:email])
    if @patron.new_record?
      @patron.name = "#{p[:first_name]} #{p[:last_name]}"
      @patron.save!
    end

    @patron.regenerate_access_token!
    PatronMailer.access_link(@patron).deliver_later

    jp = params.require(:print_job).permit(
      :model_file,
      :url,
      :filament_color,
      :notes,
      :pickup_location
    )
    @print_job = @patron.print_jobs.build(jp)
    @print_job.status = 'pending'

    if @print_job.save
      redirect_to thank_you_path
    else
      flash.now[:alert] = @print_job.errors.full_messages.to_sentence
      render :submit, status: :unprocessable_entity
    end
  end

  # Confirmation page after a successful print-job submission
  def thank_you
  end

  # Show form where a patron enters their email to request a magic link
  def token_request
  end

  # Handle the email-submission for a magic-link request
  def send_token
    p = params.require(:patron).permit(:email)
    @patron = Patron.find_by(email: p[:email])

    unless @patron
      flash.now[:alert] = "We couldn't find that email address."
      return render :token_request, status: :unprocessable_entity
    end

    @patron.regenerate_access_token!
    PatronMailer.access_link(@patron).deliver_later
    redirect_to token_thank_you_path
  end

  # Confirmation page after sending the magic-link email
  def token_thank_you
  end

  # Patron dashboard: lists their print jobs
  def dashboard
    @print_jobs = @patron.print_jobs.order(created_at: :desc)
  end

  # Show details for a single print job
  def show
    # @print_job is already loaded by load_print_job

    # If there's a conversation, show only patron-visible messages
    if @print_job.conversation
      @messages = @print_job.conversation.messages
                          .where(staff_note_only: false)
                          .order(:created_at)
    else
      @messages = []
    end

    # Prepare an empty message for the form
    @new_message = Message.new
  end

  # Handle a patron posting a message
  def create_message
    # find or build the conversation
    @conversation = @print_job.conversation || @print_job.build_conversation
    @conversation.save if @conversation.new_record?

    # create the message as the patron
    msg = @conversation.messages.create!(
      body:   params.dig(:message, :body),
      author: @patron
    )

    # TODO: notify staff users, e.g.:
    # StaffMailer.with(message: msg).new_patron_message.deliver_later

    redirect_to job_path(@print_job, token: @patron.access_token),
                notice: 'Your message has been sent.'
  end

  private

  # Load and validate patron by magic-link token (in params or session)
  def load_patron
    token = params[:token] || session[:patron_token]
    head :unauthorized and return unless token

    @patron = Patron.find_by(access_token: token)
    head :unauthorized and return unless @patron
    unless @patron.token_valid?
      @patron.expire_token!
      head :unauthorized and return
    end

    session[:patron_token] ||= token
  end

  # Load the print job scoped to the current patron
  def load_print_job
    @print_job = @patron.print_jobs.find(params[:id])
  end
end
