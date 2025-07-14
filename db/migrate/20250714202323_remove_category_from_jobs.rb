class RemoveCategoryFromJobs < ActiveRecord::Migration[7.1]
  def change
    remove_column :jobs, :category, :string
  end
end
