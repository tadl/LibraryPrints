# app/models/scan_job.rb
class ScanJob < Job
  self.table_name = 'jobs'

  has_many_attached :scan_images

  validates :category, inclusion: { in: %w[Patron Staff Assistive\ Aid Fidget Scan] }
  validates :print_type, inclusion: { in: %w[FDM Resin Scan] }  # if you still need that

  validates :status, presence: true

  # Scan‐specific
  validates :spray_ok, inclusion: { in: [true, false] }
  validates :notes,    length: { maximum: 500 }, allow_blank: true
end
