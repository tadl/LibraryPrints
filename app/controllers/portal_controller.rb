# app/controllers/portal_controller.rb
class PortalController < ApplicationController
  layout 'application'

  # Load patron for dashboard and job details only
  before_action :load_patron, only: [:dashboard, :show]

  # Public landing page with info and submission form
  def home
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

    # Generate a fresh access token and e-mail link
    @patron.regenerate_access_token!
    PatronMailer.access_link(@patron).deliver_later

    # Build the print job tied to this patron
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
      flash.now[:alert] = @print_job.errors.full_messages.join(", ")
      render :home, status: :unprocessable_entity
    end
  end

  # Simple thank-you confirmation page
  def thank_you
  end

  # Patron dashboard, shows previous and current jobs
  def dashboard
    @print_jobs = @patron.print_jobs.order(created_at: :desc)
  end

  # Show details about a single print job
  def show
    @print_job = @patron.print_jobs.find(params[:id])
  end

  private

  # Load and validate patron by magic-link token
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
