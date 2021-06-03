class ObjectSystem < Object
  attr_accessor :systemPlanets
  attr_accessor :x
  attr_accessor :y
  attr_accessor :name
  def initialize (args, availablePlanetNames)
    @planetCount = randr(1, 6)
    @systemPlanets = []
    generationCount = @planetCount
    until generationCount == 0
      planetName = availablePlanetNames.sample()
      availablePlanetNames.pop(planetName)
      @systemPlanets << ObjectPlanet.new(args, planetName)
      generationCount -= 1
    end

    @x = randr(0, args.grid.right)
    @y = randr(0, args.grid.top)
    
    @name = "George"

  end

  def draw args
    location = [@x, @y]
    return location
  end
end