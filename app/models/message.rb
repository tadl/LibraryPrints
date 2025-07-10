class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :author, polymorphic: true   # StaffUser or Patron (if you choose)

  validates :body, presence: true
end
