# frozen_string_literal: true

class ObjectSystem < Object
  attr_accessor :systemPlanets
  attr_accessor :x
  attr_accessor :y
  attr_accessor :name
  def initialize(args)
    @planetCount = randr(3, 6)
    @systemPlanets = []
    generationCount = @planetCount
    until generationCount.zero?
      planetName = $availablePlanetNames.sample
      $availablePlanetNames.pop(planetName)
      @systemPlanets << ObjectPlanet.new(args, planetName)
      generationCount -= 1
    end

    @x = randr(0, args.grid.right)
    @y = randr(0, args.grid.top)

    @name = $availablePlanetNames.sample
    $availablePlanetNames.pop(@name)
  end

  def draw(_args)
    location = [@x, @y]
    location
  end
end
