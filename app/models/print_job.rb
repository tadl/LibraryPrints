# app/models/print_job.rb
class PrintJob < ApplicationRecord
  belongs_to :patron

  # Active Storage attachment for the uploaded 3D model
  has_one_attached :model_file

  # Status workflow
  enum status: {
    pending:           0,
    info_requested:    1,
    queued:            2,
    printing:          3,
    ready_for_pickup:  4,
    archived:          5
  }

  # Validations
  validates :status, presence: true

  # URL is optional but must be well-formed when present
  validates :url,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                      message: 'must be a valid URL' },
            allow_blank: true

  # Ensure pickup_location is always set
  validates :pickup_location,
            presence: true,
            inclusion: {
              in:  ->(_) { PickupLocation.active.pluck(:code) },
              message: "%{value} is not a valid pickup location"
            }

  # Filament color free-text (we’ll drive the list from the form/UI)
  validates :filament_color, length: { maximum: 50 }, allow_blank: true

  # Require _either_ a model_file _or_ a URL
  validate :url_or_model_file_present

  private

  def url_or_model_file_present
    if url.blank? && !model_file.attached?
      errors.add(:base, "You must provide either a file upload or a URL")
    end
  end
end
