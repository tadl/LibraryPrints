# db/migrate/20250713012406_rename_job_type_to_category_and_add_sti_type.rb
class RenameJobTypeToCategoryAndAddStiType < ActiveRecord::Migration[7.1]
  def up
    # 1) If you still have a job_type column (your “category”), rename it:
    if column_exists?(:jobs, :job_type)
      rename_column :jobs, :job_type, :category
    end

    # 2) Add the Rails-standard STI column `type`, defaulting to PrintJob.
    unless column_exists?(:jobs, :type)
      add_column :jobs, :type, :string, null: false, default: "PrintJob"
    end

    # 3) If you already have some real scan‐jobs in the old table,
    #    make sure those rows get the correct subclass:
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE jobs
          SET type = 'ScanJob'
          WHERE print_type = 'Scan';
        SQL
      end
    end
  end

  def down
    # Undo in reverse order
    remove_column :jobs, :type if column_exists?(:jobs, :type)
    if column_exists?(:jobs, :category)
      rename_column :jobs, :category, :job_type
    end
  end
end
