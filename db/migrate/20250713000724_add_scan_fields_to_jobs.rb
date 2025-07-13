class AddScanFieldsToJobs < ActiveRecord::Migration[7.1]
  def change
    # only add the spray_ok column if it doesn't already exist
    unless column_exists?(:jobs, :spray_ok)
      add_column :jobs, :spray_ok, :boolean, null: false, default: false,
                 comment: 'Whether it’s OK to apply scanning spray/powder to the object'
    end
  end
end

