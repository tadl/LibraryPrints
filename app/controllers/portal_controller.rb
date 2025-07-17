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
  # PRINT/FIDGET/ASSISTIVE FORM
  #
  def submit_print
    @type = params[:type] || 'patron'
    @job  = PrintJob.new

    if @type.in?(%w[fidget assistive])
      # load only the models for this category
      @printable_models = PrintableModel
        .joins(:category)
        .where(categories: { name: @type.capitalize })
        .order(:position)

      # render the matching template (submit_fidget or submit_assistive)
      return render :"submit_#{@type}"
    end

    # default “patron” flow
    render :submit_print
  end

  #
  # SAVE ANY TYPE OF PRINT JOB
  #
  #
  # SAVE ANY TYPE OF PRINT JOB
  #
  def create_print_job
    @patron = find_or_create_patron
    @job    = PrintJob.new(print_job_params)
    @job.patron = @patron

    if params[:type].in?(%w[fidget assistive])
      @job.print_type = PrintType.find_by!(code: 'fdm')

      # associate the selected PrintableModel and copy its STL
      if (pm_id = params.dig(:job, :printable_model_id)).present?
        pm = PrintableModel.find(pm_id)
        @job.printable_model = pm
        @job.model_file.attach(pm.model_file.blob) if pm.model_file.attached?
      end
    end

    @job.category = Category.find_by!(name: params[:type].to_s.capitalize)
    @job.status   = Status.find_by!(code: 'pending')

    unless verify_recaptcha(model: @job)
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      template = params[:type] == 'fidget' ? :submit_fidget : :submit_print
      return render template, status: :unprocessable_entity
    end

    send_magic_link

    if @job.save
      redirect_to thank_you_path(kind: params[:type])
    else
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      template = params[:type] == 'fidget' ? :submit_fidget : :submit_print
      render template, status: :unprocessable_entity
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
    @job    = ScanJob.new(scan_job_params)
    @job.patron   = @patron
    @job.category = Category.find_by!(name: 'Patron')
    @job.status   = Status.find_by!(code: 'pending')

    unless verify_recaptcha(model: @job)
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      return render :submit_scan, status: :unprocessable_entity
    end

    send_magic_link

    if @job.save
      redirect_to thank_you_path(kind: 'scan')
    else
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      render :submit_scan, status: :unprocessable_entity
    end
  end

  # Shared thank you page
  def thank_you
    @kind = params[:kind]
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
    @jobs = @patron.jobs.order(created_at: :desc).page(params[:page]).per(10)
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

  # Load or authenticate the patron, handling ?token=… for both dashboard and show
  def load_patron
    if params[:token].present?
      # 1) find by token, validate, set cookie…
      @patron = Patron.find_by(access_token: params[:token])
      unless @patron&.token_valid?
        return redirect_to login_path
      end

      cookies.encrypted[:patron_id] = {
        value:    @patron.id,
        httponly: true,
        expires:  4.hours.from_now
      }

      # 2) redirect to the clean URL
      if action_name == 'dashboard'
        return redirect_to dashboard_path
      else
        return redirect_to job_path(params[:id])
      end

    elsif cookies.encrypted[:patron_id].present?
      # cookie-only flow
      @patron = Patron.find_by(id: cookies.encrypted[:patron_id])
      unless @patron&.token_valid?
        return redirect_to login_path
      end

    else
      # no token, no cookie → ask them to log in
      return redirect_to login_path
    end
  end

  # Scoped load of this user’s job (STI)
  def load_job
    @job = @patron.jobs.find(params[:id])
  end

  def print_job_params
    params.require(:job).permit(
      # regular-print fields
      :model_file,
      :url,
      # shared
      :filament_color,
      :notes,
      :pickup_location,
      # fidget-only
      :printable_model_id,
      :print_type
    )
  end

end
