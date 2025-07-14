# app/models/scan_job.rb
class ScanJob < Job
  self.table_name = 'jobs'

  has_one_attached :scan_image

  validates :category, inclusion: { in: %w[Patron Staff Assistive\ Aid Fidget Scan] }

  validates :status, presence: true

  # Scan‐specific
  validates :spray_ok, inclusion: { in: [true, false] }
  validates :notes,    length: { maximum: 500 }, allow_blank: true
end
