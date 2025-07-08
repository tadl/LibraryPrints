class RemoveQuantityFromPrintJobs < ActiveRecord::Migration[7.1]
  def change
    remove_column :print_jobs, :quantity, :integer
  end
end
