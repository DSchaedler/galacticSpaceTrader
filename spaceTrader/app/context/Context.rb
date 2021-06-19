# frozen_string_literal: true

require 'app/context/context_planet_map'
require 'app/context/context_planet_menu'
require 'app/context/context_galaxy_map'

# super class for scene_main contexts.
class Context
  def initialize
    args.outputs = []
  end
end
