class CreateStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :statuses do |t|
      t.string :name
      t.string :code
      t.integer :position

      t.timestamps
    end
    add_index :statuses, :code
  end
end
