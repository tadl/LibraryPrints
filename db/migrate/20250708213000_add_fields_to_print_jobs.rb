# db/migrate/20250708213000_add_fields_to_print_jobs.rb
class AddFieldsToPrintJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :print_jobs, :url,              :string
    add_column :print_jobs, :filament_color,   :string
    add_column :print_jobs, :pickup_location,  :string
  end
end
