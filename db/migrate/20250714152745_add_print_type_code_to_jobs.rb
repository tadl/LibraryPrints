class AddPrintTypeCodeToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :print_type_code, :string
  end
end
