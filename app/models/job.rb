# app/models/job.rb
class Job < ApplicationRecord
  # single‐table inheritance on the `type` column
  # (you’ve already set inheritance_column elsewhere)
  
  belongs_to :patron
  belongs_to :status

  # Declare this here so RailsAdmin (and AR) know about it
  belongs_to :assigned_printer,
             class_name: 'Printer',
             optional:   true

  has_one  :conversation, dependent: :destroy
  after_create :build_conversation!

  validates :status, presence: true

  scope :with_status, ->(code) {
    joins(:status).where(statuses: { code: code })
  }

  private

  def build_conversation!
    create_conversation! unless conversation
  end
end
