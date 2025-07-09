class CreateFilamentColors < ActiveRecord::Migration[7.1]
  def change
    create_table :filament_colors do |t|
      t.string :name
      t.string :code
      t.integer :position

      t.timestamps
    end
  end
end
