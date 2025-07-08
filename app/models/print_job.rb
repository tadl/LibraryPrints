class PrintJob < ApplicationRecord
  belongs_to :patron

  enum status: {
    pending:          0,
    info_requested:  1,
    queued:          2,
    printing:        3,
    ready_for_pickup:4,
    archived:        5
  }

  validates :status, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
