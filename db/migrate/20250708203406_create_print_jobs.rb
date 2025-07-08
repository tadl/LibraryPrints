class CreatePrintJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :print_jobs do |t|
      t.references :patron, null: false, foreign_key: true
      t.integer :status
      t.text :description
      t.integer :quantity
      t.text :notes

      t.timestamps
    end
  end
end
