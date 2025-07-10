class AddStaffNoteOnlyToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :staff_note_only, :boolean, default: false, null: false
  end
end
