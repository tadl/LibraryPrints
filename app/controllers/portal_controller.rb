# app/controllers/portal_controller.rb
class PortalController < ApplicationController
  layout 'application'

  # these need a logged-in patron
  before_action :load_patron, only: %i[dashboard show create_message]
  before_action :load_job,    only: %i[show create_message]

  # Public landing page
  def home
  end

  # Show the “Submit a New Request” form
  def submit
    @job = PrintJob.new
  end

  # Handle submission of a new 3D print job
  def create_job
    # find or create the Patron
    p_params = params.require(:patron).permit(:first_name, :last_name, :email)
    @patron   = Patron.find_or_initialize_by(email: p_params[:email])
    if @patron.new_record?
      @patron.name = "#{p_params[:first_name]} #{p_params[:last_name]}"
      @patron.save!
    end

    # regenerate token & send magic-link
    @patron.regenerate_access_token!
    PatronMailer.access_link(@patron).deliver_later

    # build a plain Job record, force it to be a PrintJob STI
    job_params = params.require(:job)
                     .permit(:model_file, :url, :filament_color, :notes, :pickup_location)

    @job           = @patron.jobs.build(job_params)
    @job.type      = 'PrintJob'    # STI discriminator
    @job.category  = 'Patron'      # if you're still using that column
    @job.status    = 'pending'     # always pending to start

    if @job.save
      redirect_to thank_you_path
    else
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      render :submit, status: :unprocessable_entity
    end
  end

  # Thank-you page post-submission
  def thank_you
  end

  # “Log in” page (enter your email)
  def token_request
  end

  # Send the magic link, and set a secure cookie
  def send_token
    patron_params = params.require(:patron).permit(:email)
    @patron = Patron.find_by(email: patron_params[:email])

    unless @patron
      flash.now[:alert] = "We couldn't find that email address."
      return render :token_request, status: :unprocessable_entity
    end

    @patron.regenerate_access_token!

    # set encrypted, secure, httponly cookie (14-day expiry)
    cookies.encrypted[:patron_id] = {
      value:     @patron.id,
      expires:   14.days.from_now,
      secure:    Rails.env.production?,
      httponly:  true,
      same_site: :lax
    }

    PatronMailer.access_link(@patron).deliver_later
    redirect_to token_thank_you_path
  end

  # “Check your inbox” confirmation
  def token_thank_you
  end

  # Patron dashboard (list of their jobs)
  def dashboard
    @jobs = @patron.jobs.order(created_at: :desc)
  end

  # Show a single job (and its visible messages)
  def show
    @messages    = @job.conversation&.messages
                      &.where(staff_note_only: false)
                      &.order(:created_at) || []
    @new_message = Message.new
  end

  # Handle a patron posting a message to the conversation
  def create_message
    @conversation = @job.conversation || @job.build_conversation
    @conversation.save if @conversation.new_record?

    @conversation.messages.create!(
      body:   params.dig(:message, :body),
      author: @patron
    )

    redirect_to job_path(@job), notice: 'Your message has been sent.'
  end

  private

  # Load/validate a patron: first via the secure cookie, else via token in URL/session
  def load_patron
    if cookies.encrypted[:patron_id].present?
      @patron = Patron.find_by(id: cookies.encrypted[:patron_id])
      head :unauthorized and return unless @patron&.token_valid?
    else
      token = params[:token] || session[:patron_token]
      head :unauthorized and return unless token

      @patron = Patron.find_by(access_token: token)
      head :unauthorized and return unless @patron&.token_valid?

      session[:patron_token] ||= token
    end
  end

  # Scoped load of this user’s job (PrintJob or ScanJob via STI)
  def load_job
    @job = @patron.jobs.find(params[:id])
  end
end
