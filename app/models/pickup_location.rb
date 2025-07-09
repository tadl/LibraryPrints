class PickupLocation < ApplicationRecord
  scope :active, -> { where(active: true) }
  validates :name, :code, presence: true
  validates :code, uniqueness: true
  default_scope { order(position: :asc) }
end
