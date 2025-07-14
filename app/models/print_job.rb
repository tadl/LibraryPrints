# app/models/print_job.rb
class PrintJob < Job
  self.table_name = 'jobs'

  belongs_to :assigned_printer,
             class_name: 'Printer',
             optional:   true

  JOB_CATEGORIES = %w[Patron Staff Assistive\ Aid Fidget Scan].freeze

  validates :category, inclusion: { in: JOB_CATEGORIES }
  validates :status,   presence: true

  # only on update do we *really* require a print_type
  with_options on: :update do
    validates :print_type,      presence: true
    validates :print_type_code, presence: true,
                                inclusion: { in: -> { PrintType.pluck(:code) } }
  end

  # everything else stays the same
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

  private

  def url_or_model_file_present
    if url.blank? && !model_file.attached?
      errors.add(:base, "You must provide either a file upload or a URL")
    end
  end
end
