class RemoveAssignedPrinterFromPrintJobs < ActiveRecord::Migration[7.1]
  def change
    remove_column :print_jobs, :assigned_printer, :string
  end
end
