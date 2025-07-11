# app/models/printer.rb
class Printer < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :print_jobs, foreign_key: :assigned_printer_id

  # if you want to allow “nil” on everything else, no further validations needed
end
