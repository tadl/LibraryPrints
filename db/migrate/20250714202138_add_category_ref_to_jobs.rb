# db/migrate/20250714202138_add_category_ref_to_jobs.rb
class AddCategoryRefToJobs < ActiveRecord::Migration[7.1]
  # define minimal versions of your models for use inside the migration
  class Job       < ApplicationRecord; self.table_name = "jobs"      end
  class Category  < ApplicationRecord; self.table_name = "categories" end

  def up
    # 1) add the column, allow nulls for now
    add_reference :jobs, :category,
                  foreign_key: true,
                  null:        true

    # 2) backfill from the old string column
    say_with_time "Backfilling jobs.category_id from jobs.category" do
      default = Category.find_by!(name: "Patron")
      Category.find_each do |cat|
        Job.where(category: cat.name).update_all(category_id: cat.id)
      end
      # anything not matched—assign it to “Patron” so we can close the null constraint
      Job.where(category_id: nil).update_all(category_id: default.id)
    end

    # 3) now make it non-null
    change_column_null :jobs, :category_id, false

    # (optional) if you no longer need the old string column you can remove it:
    # remove_column :jobs, :category, :string
  end

  def down
    # if you removed the old column in `up`, you'd have to re-add it here.
    remove_reference :jobs, :category, foreign_key: true
  end
end
