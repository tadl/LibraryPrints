class AddAssignedPrinterToPrintJobs < ActiveRecord::Migration[7.1]
  def change
    add_reference :print_jobs,
                  :assigned_printer,
                  foreign_key: { to_table: :printers },
                  index: true,
                  null: true
  end
end
