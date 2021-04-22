# Require Files
require 'lib/data_arrays_lib.rb' # EXOPLANET_NAMES, ELEMENT_NAMES, ELEMENT_SYMBOLS

# Define Constants

ALPHANUM = (('A'..'Z').to_a + (0..9).to_a) # Creates an array containing A-Z + 0-9

COMMODITIES = ["Air", "Water", "Microprocessors"]
SUPPLIES = []

PLANET_TYPES = ["T", "J", "R", "O", "D", "A", "G", "I", "T"]
PLANET_TYPE_STRINGS = ["Terran", "Jungle", "Rock", "Ocean", "Desert", "Arctic", "Gas", "Inferno", "Toxic"]

def tick args # Called by engine every game cycle.
  init(args)
  main(args)

  args.outputs.primitives << args.gtk.current_framerate_primitives # Display debug data. Comment to disable.
end

def init args # Used to set initial values in args.state, etc. Self latching to only run once.
  args.state.initDone ||= 0

  if args.state.initDone == 0
    args.state.planets = []
    args.state.persistent_labels = {}

    start(args)

    args.state.initDone = 1
  end
end

def start args # Runs once at the beginning of the game.
  # Populate planets if the store is empty
  if args.state.planets == []
    rnd_planet(args)
    rnd_planet(args)
    rnd_planet(args)
  end

  args.state.planetIndex ||= 0 # Set the default index position
  args.state.updateNeeded ||= false
end

# Called every tick by "tick". Main game code should originate here.
def main args

  # LOCAL VARIABLES
  # Reference Screen Limits
  top = args.grid.top
  right = args.grid.right

  # KEYPRESS EVENTS
  # Change the index position on keypress
  if args.inputs.keyboard.keys != []
    
    if args.inputs.keyboard.key_up.left 
      if args.state.planetIndex > 0
        args.state.planetIndex -= 1
      end
    elsif args.inputs.keyboard.key_up.right
      if args.state.planetIndex < args.state.planets.length() - 1
        args.state.planetIndex += 1
      end
    end

    args.state.updateNeeded = true
  end

  # GET STATE
  index = args.state.planetIndex # Current Planet number
  planet = args.state.planets[index] # Current Planet reference
  planetTypeString = PLANET_TYPE_STRINGS[PLANET_TYPES.index(planet[:type])] # Determine Planet Type
  ptsDowncase = planetTypeString.downcase # Image files are downcase, only used to fetch those.

  # CYCLE UPDATE
  if args.state.tick_count % 60 == 0 || args.state.updateNeeded == true

    args.state.updateNeeded = false
    
    # Generate Persistent Labels
    args.state.persistent_labels[:planetIndex] = {x: 100, y: top - 100, text: "ID: #{index}", primitive_marker: :label}
    args.state.persistent_labels[:planetName] = {x: 100, y: top - 120, text: "Name: #{planet[:name]}", primitive_marker: :label}
    args.state.persistent_labels[:planetType] = {x: 100, y: top - 140, text: "Type: #{planetTypeString}", primitive_marker: :label}
    args.state.persistent_labels[:planetElements] = {x: 100, y: top - 160, text: "Elements: #{planet[:elements]}", primitive_marker: :label}
    args.state.persistent_labels[:planetCommodities] = {x: 100, y: top - 180, text: "Commodities: #{planet[:commodities]}", primitive_marker: :label}
  end

  # GAME DRAW

  # Draw persistent labels
  draw_persistent_labels(args)

  # Draw planet sprite
  sprite_array = [right / 2, top / 2, 300, 300, "sprites/PixelPlanets/#{ptsDowncase}#{index}.png"] #+ [0, 255] + args.state.planetHue
  args.outputs.primitives << sprite_array.sprite

end

def draw_persistent_labels args
  args.state.persistent_labels.each do |key, value|
    args.outputs.primitives << args.state.persistent_labels[key]
  end
end

def rnd_planet args # Creates a new planet. Returns the position of this planet in args.state.planets
  # Generate Characteristics
  type = PLANET_TYPES.sample
  name = rnd_planetName(type)

  # Choose random elements
  s = ELEMENT_SYMBOLS.shuffle
  elements = [s[0], s[1], s[2]]

  # Choose random commodities
  s = COMMODITIES.shuffle
  commodities = [s[0], s[1], s[2]]
  
  store = args.state.planets # Get current planets
  len = store.length() # Determine what number planet this is

  args.state.planets[len] = {name: name, type: type, elements: elements, commodities: commodities} # Store the new planet

  return len
end

#DEPRECIATED
def rnd_planetName type # Generates a random planet name ex. "T-AB01". Type determines leading character.
  randomIdentifier = (0...4).map { # make array of length 4
    |n| ALPHANUM.sample           # put a random ALPHANUM in 'n'
  }.join

  planetName = type.to_s + "-" + randomIdentifier.to_s # Concatinate final name

  return planetName
end

def randr (min, max) # Returns a random number in a range of min, max. Not included in engine for some reason
  rand(max - min) + min
end