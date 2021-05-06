# Require our various files.
# Clustered Data
require 'app/constants.rb'
# Classes
require 'app/background.rb'
require 'app/planet.rb'
require 'app/textboxMaking.rb'

PLAYFIELD = [180, 0, 1280, 720]

# Main game class
class Game
  attr_gtk # Magic

  # Runs once when game instance created
  # CANT USE ARGS
  def initialize
    # Game Instance Variables
    @planets = []
    @planetIndex = 0
    @setupDone = false

    # Generate Planets
    i = 0
    until i > 10 do
      @planets[i] = Planet.new()
      i += 1
    end

    @background = Background.new(stars: 150, maxStarSize: 6, minX: PLAYFIELD[0], minY: 0)
  end

  # If you can't do it in initialize because you need args, do it here.
  def setup args
    @setupDone = true
    
    @background.drawBackground(args, r: 20, g: 24, b: 46) # A nice space blue
    for planet in @planets
      planet.drawPlanet(args)
    end
  end

  # Main loop
  def tick

    if @setupDone == false
      setup(args)
    end

    # Tick Begin
    
    i=0
    for planet in @planets
      for material in RESOURCES
        @planets[i].materials[material][:store] += @planets[i].materials[material][:store]
      end
      i += 1
    end
    
    for planet in @planets
      if args.inputs.mouse.inside_rect? [planet.x, planet.y, 28, 28]
        planet.drawInfo(args)
      end
    end

    #@planets[@planetIndex].drawInfo(args)
    # Tick End
    #args.outputs.primitives << args.gtk.current_framerate_primitives # Display debug data. Comment to disable.
  end

  # Other game instance methods
end

# Engine loop. Creates the game instance, then immdiately routes tick to $game.tick.
# Don't put anything else here, put it in $game.tick.
def tick args
  $game ||= Game.new
  $game.args = args # This is unavailable in Game.initialize, so plan accordingly.
  $game.tick
end

# Engine methods

# Produces random number in range min through max.
def randr (min, max) 
  rand(max - min) + min
end

# Converts a string for a hexidecimal color value to an array of RGB values.
def hexToRGB (hexstring)
  rgbArray = hexstring.gsub("#", "").split('').each_slice(2).map {|e| e.join.to_i(16)}
  return rgbArray
end

# Resets the game object, effectively making a clean reset.
def resetGame
  $game = nil
  $gtk.reset
end

# Resets the game object, using the system time as a seed.
def resetGameRandom
  $game = nil
  $gtk.reset seed: Time.new
end