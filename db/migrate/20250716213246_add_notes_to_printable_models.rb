class AddNotesToPrintableModels < ActiveRecord::Migration[7.1]
  def change
    add_column :printable_models, :notes, :text
  end
end
