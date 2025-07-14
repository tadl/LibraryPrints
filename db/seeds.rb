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

[
  ['FDM',   'fdm'],
  ['Resin', 'resin']
].each.with_index(1) do |(n,c), i|
  PrintType.find_or_create_by!(code: c) do |pt|
    pt.name     = n
    pt.position = i
  end
end

categories = [
  { name: 'Patron',        position: 1 },
  { name: 'Staff',         position: 2 },
  { name: 'Assistive Aid', position: 3 },
  { name: 'Fidget',        position: 4 },
]

categories.each do |attrs|
  cat = Category.find_or_initialize_by(name: attrs[:name])
  # only update position if changed (optional)
  if cat.new_record? || cat.position != attrs[:position]
    cat.position = attrs[:position]
    cat.save!
  end
end
