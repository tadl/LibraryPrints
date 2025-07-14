class CreatePrintTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :print_types do |t|
      t.string :name
      t.string :code
      t.integer :position

      t.timestamps
    end
    add_index :print_types, :code, unique: true
  end
end
