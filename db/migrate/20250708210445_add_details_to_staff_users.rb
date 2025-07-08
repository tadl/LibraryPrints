# db/migrate/20250708_add_details_to_staff_users.rb
class AddDetailsToStaffUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :staff_users, :name,       :string
    add_column :staff_users, :avatar_url, :string
    # If you haven’t already, add uid for OmniAuth:
    add_column :staff_users, :uid,        :string, null: false
    add_index  :staff_users, :uid, unique: true
  end
end
