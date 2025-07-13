# app/models/printer.rb
class Printer < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :print_jobs, foreign_key: :assigned_printer_id
  belongs_to :pickup_location
end
