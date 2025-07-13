# app/models/conversation.rb
class Conversation < ApplicationRecord
  belongs_to :job
  has_many   :messages, -> { order(:created_at) }, dependent: :destroy
end
