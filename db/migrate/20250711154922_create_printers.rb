# db/migrate/20250710_create_printers.rb
class CreatePrinters < ActiveRecord::Migration[7.1]
  def change
    create_table :printers do |t|
      t.string :name,        null: false
      t.string :printer_type
      t.string :printer_model
      t.string :bed_size
      t.string :location

      t.timestamps
    end

    add_index :printers, :name, unique: true
  end
end
