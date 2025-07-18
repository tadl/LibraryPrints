# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  include ActionController::MimeResponds

  before_action :authenticate_staff!

  # GET /reports/print(.:format)
  def print
    # pick a year/month (fallback to last month)
    year  = params[:year].to_i.nonzero?  || (Date.current - 1.month).year
    month = params[:month].to_i.nonzero? || (Date.current - 1.month).month
    @period = Date.new(year, month)

    completed = PrintJob.where(completion_date: @period.all_month)
    cancelled = PrintJob
                  .joins(:status)
                  .where(statuses: { code: 'cancelled' })
                  .where(updated_at: @period.all_month)

    # union both sets
    job_ids = completed.ids + cancelled.ids
    jobs    = PrintJob.where(id: job_ids)

    # counts
    @orders_count     = completed.count
    @cancelled_count  = cancelled.count
    @distinct_patrons = jobs.select(:patron_id).distinct.count

    # fdm / resin only on completed
    fdm_scope   = completed.joins(:print_type).where(print_types: { code: 'fdm' })
    resin_scope = completed.joins(:print_type).where(print_types: { code: 'resin' })

    @fdm_count      = fdm_scope.count
    @resin_count    = resin_scope.count
    @resin_ml       = resin_scope.sum(:resin_volume_ml).to_i

    # multi-color across both
    @multiple_count = jobs.where(filament_color: 'multiple').count

    # total quantity (staff-entered)
    @total_quantity = completed.sum(:quantity)

    # unique designs among completed only
    pm_count       = completed.where.not(printable_model_id: nil)
                              .distinct
                              .count(:printable_model_id)
    jobs_without_pm = completed.where(printable_model_id: nil)
    urls           = jobs_without_pm.pluck(:url).reject(&:blank?)
    files          = jobs_without_pm
                       .select { |j| j.model_file.attached? }
                       .map { |j| j.model_file.filename.to_s }
    @unique_designs = pm_count + (urls + files).uniq.size

    @filament_grams  = fdm_scope.sum(:actual_weight).to_i

    # breakdown by category over all jobs
    @category_counts = jobs
                         .joins(:category)
                         .group('categories.name')
                         .count

    respond_to do |format|
      format.html
      format.json
    end
  end

  private

  # exactly the same redirect that RailsAdmin uses:
  def authenticate_staff!
    return if current_staff_user

    session[:user_return_to] = request.fullpath
    redirect_to '/auth/google_oauth2'
  end
end
