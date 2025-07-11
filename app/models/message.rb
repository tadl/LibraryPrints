class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :author, polymorphic: true   # StaffUser or Patron (if you choose)

  has_many_attached :images

  validates :body, presence: true
end
