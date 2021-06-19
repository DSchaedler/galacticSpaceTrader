# frozen_string_literal: true

require 'app/context/context_planet_map.rb'
require 'app/context/context_planet_menu.rb'
require 'app/context/context_galaxy_map.rb'

# super class for scene_main contexts.
class Context
  def initialize
    args.outputs = []
  end
end
