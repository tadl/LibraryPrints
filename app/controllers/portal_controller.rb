# app/controllers/portal_controller.rb
class PortalController < ApplicationController
  helper :portal
  layout 'application'

  # Need a logged-in patron for dashboard/show/create_message
  before_action :load_patron, only: %i[dashboard show create_message]
  before_action :load_job,    only: %i[show create_message]

  # Public landing page
  def home
  end

  #
  # PRINT JOB
  #
  def submit_print
    @job = PrintJob.new
  end

  def create_print_job
    @patron = find_or_create_patron
    send_magic_link

    @job = PrintJob.new(print_job_params)
    @job.patron   = @patron
    @job.category = 'Patron'
    @job.status   = 'pending'

    if @job.save
      redirect_to thank_you_path
    else
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      render :submit_print, status: :unprocessable_entity
    end
  end

  #
  # SCAN JOB
  #
  def submit_scan
    @job = ScanJob.new
  end

  def create_scan_job
    @patron = find_or_create_patron
    send_magic_link

    # build a ScanJob directly so attachments and STI behave
    @job = ScanJob.new(scan_job_params)
    @job.patron   = @patron
    @job.category = 'Patron'
    @job.status   = 'pending'

    if @job.save
      redirect_to thank_you_path
    else
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      render :submit_scan, status: :unprocessable_entity
    end
  end

  # Shared thank you page
  def thank_you
  end

  # “Log in” page (enter your email)
  def token_request
  end

  # Send the magic link, and set secure cookie
  def send_token
    @patron = Patron.find_by(email: params.dig(:patron, :email))
    unless @patron
      flash.now[:alert] = "We couldn't find that email address."
      return render :token_request, status: :unprocessable_entity
    end

    send_magic_link
    redirect_to token_thank_you_path
  end

  # “Check your inbox” confirmation
  def token_thank_you
  end

  # Patron dashboard (list of all jobs)
  def dashboard
    @jobs = @patron.jobs.order(created_at: :desc)
  end

  # Show a single job (and its messages)
  def show
    @messages    = @job.conversation&.messages&.where(staff_note_only: false)&.order(:created_at) || []
    @new_message = Message.new
  end

  # Patron posts a message
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

  # DRY: find or build patron from form
  def find_or_create_patron
    p = params.require(:patron).permit(:first_name, :last_name, :email)
    patron = Patron.find_or_initialize_by(email: p[:email])
    if patron.new_record?
      patron.name = "#{p[:first_name]} #{p[:last_name]}"
      patron.save!
    end
    patron
  end

  # DRY: regenerate token & send magic link
  def send_magic_link
    @patron.regenerate_access_token!
    PatronMailer.access_link(@patron).deliver_later
  end

  # Strong params for print jobs
  def print_job_params
    params.require(:job).permit(
      :model_file,
      :url,
      :filament_color,
      :notes,
      :pickup_location
    )
  end

  def scan_job_params
    params.require(:job).permit(
      :scan_image,
      :spray_ok,
      :notes,
      :pickup_location
    )
  end

  def load_patron
    if cookies.encrypted[:patron_id].present?
      @patron = Patron.find_by(id: cookies.encrypted[:patron_id])
      head :unauthorized and return unless @patron&.token_valid?

    elsif params[:token].present?
      @patron = Patron.find_by(access_token: params[:token])
      head :unauthorized and return unless @patron&.token_valid?

      cookies.encrypted[:patron_id] = {
        value:   @patron.id,
        httponly: true,
        expires: 4.hours.from_now
      }
      session.delete(:patron_token)

    else
      head :unauthorized and return
    end
  end

  # Scoped load of this user’s job (STI)
  def load_job
    @job = @patron.jobs.find(params[:id])
  end
end
