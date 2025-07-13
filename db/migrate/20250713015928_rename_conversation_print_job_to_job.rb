class RenameConversationPrintJobToJob < ActiveRecord::Migration[7.1]
  def change
    rename_column :conversations, :print_job_id, :job_id
    add_foreign_key :conversations, :jobs, column: :job_id
  end
end
