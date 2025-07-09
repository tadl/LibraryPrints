# app/controllers/portal_controller.rb
class PortalController < ApplicationController
  layout 'application'

  # Only dashboard and show require a logged-in patron (via magic token)
  before_action :load_patron, only: [:dashboard, :show]

  # Public landing page with info and a link to the submission form
  def home
    # could show overview, queue stats, links to submit or request a token
  end

  # Display the 3D print submission form
  def submit
    @print_job = PrintJob.new
  end

  # Handle print job submission from public form
  def create_job
    # Find or create a patron by email
    p = params.require(:patron).permit(:first_name, :last_name, :email)
    @patron = Patron.find_or_initialize_by(email: p[:email])
    if @patron.new_record?
      @patron.name = "#{p[:first_name]} #{p[:last_name]}"
      @patron.save!
    end

    # Generate a fresh access token and email link
    @patron.regenerate_access_token!
    PatronMailer.access_link(@patron).deliver_later

    # Build and save the print job
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
  def create_token_request
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
    @print_job = @patron.print_jobs.find(params[:id])
  end

  private

  # Load and validate patron by magic-link token (in params or session)
  def load_patron
    token = params[:token] || session[:patron_token]
    head :unauthorized and return unless token

    @patron = Patron.find_by(access_token: token)
    head :unauthorized and return unless @patron

    # Expire tokens older than 7 days
    unless @patron.token_valid?
      @patron.expire_token!
      head :unauthorized and return
    end

    # Store token in session for subsequent requests
    session[:patron_token] ||= token
  end
end
