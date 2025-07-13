# app/models/job.rb
class Job < ApplicationRecord
  # single‐table inheritance on the `type` column
  # (you’ve already set inheritance_column elsewhere)
  
  belongs_to :patron

  # Declare this here so RailsAdmin (and AR) know about it
  belongs_to :assigned_printer,
             class_name: 'Printer',
             optional:   true

  has_one  :conversation, dependent: :destroy
  after_create :build_conversation!

  enum status: {
    pending:           0,
    info_requested:    1,
    queued:            2,
    printing:          3,
    ready_for_pickup:  4,
    archived:          5
  }

  validates :status, presence: true

  private

  def build_conversation!
    create_conversation! unless conversation
  end
end
