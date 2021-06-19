# frozen_string_literal: true

require 'app/context/context_planet_map'
require 'app/context/context_planet_menu'
require 'app/context/context_galaxy_map'

class Context
  def initialize
    args.outputs = []
  end
end
