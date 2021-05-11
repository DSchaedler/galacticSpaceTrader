# Require our various files.
# Clustered Data
require 'app/constants.rb'
# Classes
require 'app/Game.rb'
require 'app/context/context.rb'
require 'app/scene/scene.rb'
require 'app/object/Object.rb'
require 'app/textboxMaking.rb'

# Engine loop. Creates the game instance, then immdiately routes tick to $game.tick.
# Don't put anything else here, put it in $game.tick.
def tick args
  $game ||= Game.new(args)
  $game.tick(args)

  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end

# Engine methods - Not associated with any game logic, these are useful shortcuts to have.

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