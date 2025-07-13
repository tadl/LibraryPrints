class AddPickupLocationToPrinters < ActiveRecord::Migration[7.1]
  def change
    add_reference :printers, :pickup_location, null: true, foreign_key: true
  end
end
