class PortalController < ApplicationController
  layout 'application'

  # Load patron for dashboard and job details only
  before_action :load_patron, only: [:dashboard, :show]

  # Public landing page with info and submission form
  def home
  end

  # Handle print job submission from public form
  def create_job
    # Find or create a patron by email
    patron_params = params.require(:patron).permit(:email, :name)
    @patron = Patron.find_or_initialize_by(email: patron_params[:email])
    if @patron.new_record?
      @patron.name = patron_params[:name]
      @patron.save!
    end

    # Generate a fresh access token and email link
    @patron.generate_access_token
    @patron.save!
    PatronMailer.access_link(@patron).deliver_later

    # Create the print job tied to this patron
    job_params = params.require(:print_job).permit(:description, :quantity, :notes)
    @print_job = @patron.print_jobs.build(job_params)
    if @print_job.save
      redirect_to thank_you_path
    else
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
