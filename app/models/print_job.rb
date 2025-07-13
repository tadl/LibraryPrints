# app/models/print_job.rb
class PrintJob < Job
  self.table_name = 'jobs'

  belongs_to :assigned_printer,
             class_name: 'Printer',
             optional:   true

  has_one_attached :model_file

  JOB_CATEGORIES = %w[Patron Staff Assistive\ Aid Fidget Scan].freeze
  PRINT_TYPES    = %w[FDM Resin Scan].freeze

  validates :category,   inclusion: { in: JOB_CATEGORIES }
  validates :print_type, inclusion: { in: PRINT_TYPES }

  validates :status, presence: true

  validates :url,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                      message: 'must be a valid URL' },
            allow_blank: true

  validates :pickup_location,
            presence: true,
            inclusion: {
              in:  ->(_) { PickupLocation.active.pluck(:code) },
              message: "%{value} is not a valid pickup location"
            }

  validates :filament_color, length: { maximum: 50 }, allow_blank: true

  validate :url_or_model_file_present

  # “Pretty” name for the pickup_location code
  def pickup_location_name
    PickupLocation.find_by(code: pickup_location)&.name ||
      pickup_location.humanize
  end

  def print_time_estimate_duration
    return unless print_time_estimate

    ActiveSupport::Duration.build(print_time_estimate.minutes)
  end

  private

  def url_or_model_file_present
    if url.blank? && !model_file.attached?
      errors.add(:base, "You must provide either a file upload or a URL")
    end
  end
end
