class AddStatusRefToJobs < ActiveRecord::Migration[7.1]
  def up
    # 1) create the statuses you need
    Job.statuses.keys.each_with_index do |code, idx|
      Status.find_or_create_by!(code: code) do |s|
        s.name     = code.humanize
        s.position = idx
      end
    end

    # 2) add the status_id column
    add_reference :jobs, :status, foreign_key: true, null: true

    # 3) backfill all existing jobs to a default
    default_status = Status.find_by(code: 'pending') || Status.first
    Job.find_each { |j| j.update_column(:status_id, default_status.id) }

    # 4) enforce NOT NULL now that every job has one
    change_column_null :jobs, :status_id, false
  end

  def down
    remove_reference :jobs, :status, foreign_key: true
  end
end
