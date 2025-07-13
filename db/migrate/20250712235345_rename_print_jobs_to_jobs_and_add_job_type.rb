# db/migrate/20250712235345_rename_print_jobs_to_jobs_and_add_job_type.rb
class RenamePrintJobsToJobsAndAddJobType < ActiveRecord::Migration[7.1]
  def change
    rename_table :print_jobs, :jobs

    # Only add job_type if it doesn't already exist
    unless column_exists?(:jobs, :job_type)
      add_column :jobs, :job_type, :string, null: false, default: "PrintJob"
    end
  end
end

