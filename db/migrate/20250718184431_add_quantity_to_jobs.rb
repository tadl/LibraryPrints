class AddQuantityToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :quantity, :integer, null: true
  end
end
