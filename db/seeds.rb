# db/seeds.rb

filament_colors = [
  { name: 'Green',       code: 'green',       position: 1 },
  { name: 'Pink',        code: 'pink',        position: 2 },
  { name: 'Yellow',      code: 'yellow',      position: 3 },
  { name: 'Red',         code: 'red',         position: 4 },
  { name: 'White',       code: 'white',       position: 5 },
  { name: 'Black',       code: 'black',       position: 6 },
  { name: 'Orange',      code: 'orange',      position: 7 },
  { name: 'Blue',        code: 'blue',        position: 8 },
]

filament_colors.each do |attrs|
  color = FilamentColor.find_or_initialize_by(code: attrs[:code])
  color.update!(name: attrs[:name], position: attrs[:position])
end

pickup_locations = [
  { name: 'Woodmere',     code: 'wood',       position: 1 },
  { name: 'East Bay',     code: 'ebb',        position: 2 },
  { name: 'Kingsley',     code: 'kbl',        position: 2 },
]

pickup_locations.each do |attrs|
  loc = PickupLocation.find_or_initialize_by(code: attrs[:code])
  loc.update!(name: attrs[:name], position: attrs[:position])
end
