# Require Files
require 'lib/data_arrays_lib.rb' # EXOPLANET_NAMES, ELEMENT_NAMES, ELEMENT_SYMBOLS
require 'lib/di_lib.rb'
require 'lib/xkcd_colors.rb'

require 'app/planetGeneration.rb'
require 'app/utils.rb'
require 'app/materialTest.rb'

# Define Constants
ALPHANUM = (('A'..'Z').to_a + (0..9).to_a) # Creates an array containing A-Z + 0-9

RESOURCES = ["Silicon", "Oxygen", "Copper", "Iron", "Carbon", "Manganese", "Nickel", "Aluminum", "Nitrogen", "Hydrogen", "Zinc"]
COMMODITIES = ["Silica", "Stone", "Sand", "Glass", "Wire", "Steel", "Machine Part", "Solar Panel", "Factory", "Space Station", "Food", "Water", "Battery", "Charged Battery", "Computer", "Energy"]

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
    di_lib(args, reset: false)

    args.state.initDone = 1
  end
end

def start args # Runs once at the beginning of the game.
  # Populate planets if the store is empty
  if args.state.planets == []
    x = 0
    until x > 9
      rnd_planet(args)
      x += 1
    end
  end

  args.state.planetIndex ||= 0 # Set the default index position
  args.state.updateNeeded ||= false
end

# Called every tick by "tick". Main game code should originate here.
def main args

  materialTest(args)

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
  planet = args.state.planets[args.state.planetIndex] # Current Planet reference

  # CYCLE UPDATE
  if args.state.tick_count % 60 == 0 || args.state.updateNeeded == true

    args.state.updateNeeded = false
    
    # Generate Persistent Labels
    args.state.persistent_labels[:planetIndex] = {x: 10, y: top - 100, text: "ID: #{args.state.planetIndex}", primitive_marker: :label}
    args.state.persistent_labels[:planetName] = {x: 10, y: top - 120, text: "Name: #{planet[:name]}", primitive_marker: :label}
    args.state.persistent_labels[:planetType] = {x: 10, y: top - 140, text: "Type: #{planet[:type]}", primitive_marker: :label}
    args.state.persistent_labels[:planetElements] = {x: 10, y: top - 160, text: "Elements: #{planet[:elements]}", primitive_marker: :label}
    args.state.persistent_labels[:planetCommodities] = {x: 10, y: top - 180, text: "Commodities: #{planet[:commodities]}", primitive_marker: :label}
  end

  # GAME DRAW

  # Draw persistent labels
  draw_persistent_labels(args)

  # Draw planet sprite
  sprite_array = [10, top / 2 - 150, 300, 300, "sprites/PixelPlanets/#{planet[:type].downcase}#{planet[:image]}.png"] #+ [0, 255] + args.state.planetHue
  args.outputs.primitives << sprite_array.sprite

end

def draw_persistent_labels args
  args.state.persistent_labels.each do |key, value|
    args.outputs.primitives << args.state.persistent_labels[key]
  end
end