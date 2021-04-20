ELEMENTS = ["H", "Li", "C", "N", "O", "Al", "Si", "Cl", "Zn", "Au"]
COMMODITIES = ["Air", "Water", "Microprocessors"]
SUPPLIES = []

PLANET_TYPES = ["T", "J", "R", "O", "D", "A", "G", "I", "T", "S"]
# Terran, Jungle, Rock, Ocean, Desert, Arctic, Gas, Inferno, Toxic, Sun

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

  # Reference Screen Limits
  top = args.grid.top
  right = args.grid.right

  # Set the default index position
  args.state.planetIndex ||= 0

  # Change the index position on keypress
  if args.inputs.keyboard.key_up.left 
    if args.state.planetIndex > 0
      args.state.planetIndex -= 1
    end
  elsif args.inputs.keyboard.key_up.right
    if args.state.planetIndex < args.state.planets.length() - 1
      args.state.planetIndex += 1
    end
  end

  # Local variables for simplicity
  index = args.state.planetIndex
  planet = args.state.planets[index]

  # Change planet hue randomly
  args.state.planetHue ||= [255, 255, 255]
  
  if args.state.tick_count % 60 == 0
    hueR = randr(170, 255)
    hueG = randr(170, 255)
    hueB = randr(170, 255)
    args.state.planetHue = [hueR, hueG, hueB]
  end

  # Offset index for sprites
  spriteIndex = index + 1
  # Draw planet sprite
  sprite_array = [right / 2, top / 2, 300, 300, "sprites/planets/planet#{spriteIndex}.png"] + [0, 255] + args.state.planetHue
  args.outputs.primitives << sprite_array.sprite

  #Draw Planet Info
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
  
  type = PLANET_TYPES.sample # Random Planet Type from Constant

  planetName = type.to_s + "-" + randomIdentifier.to_s # Concatinate final name

  return planetName
end

def rnd_planetElements
  # Select set of 3 random elements
  s = ELEMENTS.shuffle
  elements = [s[0], s[1], s[2]]
  return elements
end

def rnd_planetComodities
  # Select set of 3 random commodities
  s = COMMODITIES.shuffle
  commodities = [s[0], s[1], s[2]]
  return commodities
end

def randr (min, max)
  rand(max - min) + min
end