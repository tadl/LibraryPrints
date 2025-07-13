# db/migrate/20250713120500_add_type_for_sti_to_jobs.rb
class AddTypeForStiToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :type, :string, null: false, default: 'PrintJob'
  end
end
