class AddPrintableModelToJobs < ActiveRecord::Migration[7.1]
  def change
    add_reference :jobs, :printable_model, null: true, foreign_key: true
  end
end
