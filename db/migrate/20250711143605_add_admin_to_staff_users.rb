class AddAdminToStaffUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :staff_users, :admin, :boolean, default: false, null: false
  end
end
