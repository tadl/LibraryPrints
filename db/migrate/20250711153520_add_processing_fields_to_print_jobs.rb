class AddProcessingFieldsToPrintJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :print_jobs, :job_type,             :string
    add_column :print_jobs, :print_type,           :string, default: 'FDM', null: false
    # we store duration in minutes as integer
    add_column :print_jobs, :print_time_estimate,  :integer
    add_column :print_jobs, :slicer_weight,        :decimal, precision: 10, scale: 2
    add_column :print_jobs, :slicer_cost,          :decimal, precision: 10, scale: 2
    add_column :print_jobs, :actual_weight,        :decimal, precision: 10, scale: 2
    add_column :print_jobs, :actual_cost,          :decimal, precision: 10, scale: 2
    add_column :print_jobs, :completion_date,      :date
    add_column :print_jobs, :assigned_printer,     :string
  end
end
