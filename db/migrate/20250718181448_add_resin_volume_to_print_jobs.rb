class AddResinVolumeToPrintJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :resin_volume_ml, :decimal, precision: 8, scale: 2
  end
end
