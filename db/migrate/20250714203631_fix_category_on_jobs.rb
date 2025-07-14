class FixCategoryOnJobs < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    change_column_null :jobs, :category_id, true

    say_with_time "Backfilling jobs.category_id from default 'Patron'" do
      default = Category.find_by!(name: 'Patron').id
      Job.where(category_id: nil).update_all(category_id: default)
    end

    change_column_null :jobs, :category_id, false

    # only add the FK if it isn't already there
    unless foreign_key_exists?(:jobs, :categories)
      add_foreign_key :jobs, :categories, validate: true
    end
  end

  def down
    remove_foreign_key :jobs, :categories if foreign_key_exists?(:jobs, :categories)
    change_column_null :jobs, :category_id, true
  end
end
