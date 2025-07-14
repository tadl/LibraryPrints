class AddPrintTypeCodeToPrinters < ActiveRecord::Migration[7.1]
  def change
    add_column :printers, :print_type_code, :string
  end
end
