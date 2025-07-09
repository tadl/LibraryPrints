class CreatePickupLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :pickup_locations do |t|
      t.string :name
      t.string :code
      t.integer :position

      t.timestamps
    end
  end
end
