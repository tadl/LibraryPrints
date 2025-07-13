# db/migrate/20250713120000_rename_job_type_to_category.rb
class RenameJobTypeToCategory < ActiveRecord::Migration[7.1]
  def change
    rename_column :jobs, :job_type, :category
  end
end
