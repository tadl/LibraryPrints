# db/migrate/20250713xxxxxx_add_device_flags_to_pickup_locations.rb
class AddDeviceFlagsToPickupLocations < ActiveRecord::Migration[7.1]
  def change
    add_column :pickup_locations, :scanner,       :boolean, default: false, null: false
    add_column :pickup_locations, :fdm_printer,   :boolean, default: false, null: false
    add_column :pickup_locations, :resin_printer, :boolean, default: false, null: false
  end
end
