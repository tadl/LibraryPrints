# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  before_action :authenticate_staff!

  # GET /reports/print
  def print
    # Pick a year/month (fallback to last month)
    year  = params[:year].to_i.nonzero?  || (Date.current - 1.month).year
    month = params[:month].to_i.nonzero? || (Date.current - 1.month).month
    @period = Date.new(year, month)

    # Only count jobs that have either a completion_date in this month
    # or that were cancelled (i.e. status = 'cancelled') last updated in this month
    completed_this_month = PrintJob.where(completion_date: @period.all_month)
    cancelled_this_month = PrintJob
                             .joins(:status)
                             .where(statuses: { code: 'cancelled' })
                             .where(updated_at: @period.all_month)

    @orders_count     = completed_this_month.count
    @cancelled_count  = cancelled_this_month.count
    @distinct_patrons = (completed_this_month + cancelled_this_month)
                          .map(&:patron_id).uniq.size

    fdm   = completed_this_month.joins(:print_type).where(print_types: { code: 'fdm' })
    resin = completed_this_month.joins(:print_type).where(print_types: { code: 'resin' })
    @fdm_count        = fdm.count
    @resin_count      = resin.count
    @resin_ml         = resin.sum(:resin_volume_ml).to_i

    # total quantity (staff-entered)
    @total_quantity   = completed_this_month.sum(:quantity)

    # unique designs
    unique_model_ids = completed_this_month.where.not(printable_model_id: nil)
                              .pluck(:printable_model_id).uniq.size
    other_designs    = (
      completed_this_month.where(printable_model_id: nil).pluck(:url) +
      completed_this_month.select { |j| j.model_file.attached? }
                           .map { |j| j.model_file.filename.to_s }
    ).uniq.size
    @unique_designs  = unique_model_ids + other_designs

    @filament_grams  = fdm.sum(:slicer_weight).to_i

    # breakdown by category name
    @category_counts = (completed_this_month + cancelled_this_month)
                         .group_by(&:category)
                         .transform_keys(&:name)
                         .transform_values(&:size)
  end

  private

  # exactly the same redirect that RailsAdmin uses:
  def authenticate_staff!
    return if current_staff_user

    session[:user_return_to] = request.fullpath
    redirect_to '/auth/google_oauth2'
  end
end
