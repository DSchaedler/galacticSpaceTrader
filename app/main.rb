# frozen_string_literal: true

# Require our various files.
# Clustered Data
require 'app/constants.rb'
# Classes
require 'app/engine.rb'
require 'app/game.rb'
require 'app/draw.rb'

require 'app/context/context.rb'
require 'app/scene/scene.rb'
require 'app/object/object.rb'
require 'app/ui/ui.rb'
require 'app/textbox_making.rb'

DEGREES_TO_RADIANS = Math::PI / 180

# Engine loop. Creates the game instance, then immdiately routes tick to $game.tick.
# Don't put anything else here, put it in $game.tick.
def tick(args)
  $game ||= Game.new(args)
  $game.tick(args)

  $debug ||= false

  $debug = !$debug if args.inputs.keyboard.key_up.tab
  args.outputs.debug << args.gtk.framerate_diagnostics_primitives if $debug
end

# Engine methods - Not associated with any game logic, these are useful shortcuts to have.

# Converts a string for a hexidecimal color value to an array of RGB values.
def hex_to_rgb(hexstring)
  hexstring.delete('#').split('').each_slice(2).map { |e| e.join.to_i(16) }
end

def gaussian(mean, stddev)
  theta = 2 * Math::PI * rand
  rho = Math.sqrt(-2 * Math.log(1 - rand))
  scale = stddev * rho
  [mean + scale * Math.cos(theta), mean + scale * Math.sin(theta)]
end
