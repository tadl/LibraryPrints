class RemovePrintTypeFromJobs < ActiveRecord::Migration[7.1]
  def change
    remove_column :jobs, :print_type, :string
  end
end
