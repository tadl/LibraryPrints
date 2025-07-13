# app/models/pickup_location.rb
class PickupLocation < ApplicationRecord
  scope :active,      -> { where(active: true) }
  scope :scanners,    -> { active.where(scanner: true) }
  scope :fdm_printers,   -> { active.where(fdm_printer: true) }
  scope :resin_printers, -> { active.where(resin_printer: true) }

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
