ELEMENTS = ["H", "Li", "C", "N", "O", "Al", "Si", "Cl", "Zn", "Au"]
COMMODITIES = ["Air", "Water", "Microprocessors"]
SUPPLIES = []

PLANET_TYPES = ["R", "G"]

ALPHANUM = (('A'..'Z').to_a + (0..9).to_a)

def tick args
  init(args)
  main(args)

  args.outputs.primitives << args.gtk.current_framerate_primitives
end

def init args
  args.state.initDone ||= 0

  if args.state.initDone == 0
    args.state.planets = []

    args.state.initDone = 1
  end
end

def main args
  # Populate planets if the store is empty
  if args.state.planets == []
    rnd_planet(args)
    rnd_planet(args)
    rnd_planet(args)
  end

  top = args.grid.top

  index = 0
  planet = args.state.planets[index]

  args.outputs.primitives << [100, top - 100, "ID: #{index}"].label
  args.outputs.primitives << [100, top - 120, "Name: #{planet[:name]}"].label
  args.outputs.primitives << [100, top - 140, "Elements: #{planet[:elements]}"].label
  args.outputs.primitives << [100, top - 160, "Commodities: #{planet[:commodities]}"].label
end

def rnd_planet args # Returns the position of this planet in args.state.planets
  # Generate Characteristics
  name = rnd_planetName()
  elements = rnd_planetElements()
  commodities = rnd_planetComodities()

  # Get current planets
  store = args.state.planets
  # Determine what number planet this is
  len = store.length()

  # Store the new planet
  args.state.planets[len] = {name: name, elements: elements, commodities: commodities}

  return len
end

def rnd_planetName  
  randomIdentifier = (0...4).map { # make array of length 4
    |n| ALPHANUM.sample           # put a random ALPHANUM in 'n'
  }.join
  
  type = PLANET_TYPES.sample

  planetName = type.to_s + "-" + randomIdentifier.to_s

  return planetName
end

def rnd_planetElements
  s = ELEMENTS.shuffle
  elements = [s[0], s[1], s[2]]
  return elements
end

def rnd_planetComodities
  s = COMMODITIES.shuffle
  commodities = [s[0], s[1], s[2]]
  return commodities
end
