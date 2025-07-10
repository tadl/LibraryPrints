class Conversation < ApplicationRecord
  belongs_to :print_job
  has_many   :messages, -> { order(:created_at) }, dependent: :destroy
end
