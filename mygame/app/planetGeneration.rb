def rnd_planet args # Creates a new planet. Returns the position of this planet in args.state.planets
  # Generate Characteristics
  type = PLANET_TYPE_STRINGS.sample
  name = EXOPLANET_NAMES.sample
  
  if type == "Inferno" || "Toxic"
    image = randr(0, 3)
  else
    image = randr(0, 5)
  end

  # Choose random elements
  s = ELEMENT_SYMBOLS.shuffle
  elements = [s[0], s[1], s[2]]

  # Choose random commodities
  s = COMMODITIES.shuffle
  commodities = [s[0], s[1], s[2]]
  
  store = args.state.planets # Get current planets
  len = store.length() # Determine what number planet this is

  args.state.planets[len] = {name: name, type: type, image: image, elements: elements, commodities: commodities} # Store the new planet

  return len
end