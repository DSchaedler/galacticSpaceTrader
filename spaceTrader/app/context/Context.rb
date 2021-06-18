# frozen_string_literal: true

require 'app/context/ContextPlanetMap.rb'
require 'app/context/ContextPlanetMenu.rb'
require 'app/context/ContextGalaxyMap.rb'

class Context
  def initialize
    args.outputs = []
  end
end
