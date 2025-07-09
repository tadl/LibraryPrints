class AddActiveToPickupLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :pickup_locations, :active, :boolean, default: true, null: false
  end
end
