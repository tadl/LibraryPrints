class CreatePrintableModels < ActiveRecord::Migration[7.1]
  def change
    create_table :printable_models do |t|
      t.string :name
      t.string :code
      t.integer :position
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
