class SceneMain < Scene
  attr_accessor :planets
  attr_accessor :planetSelect
  attr_accessor :planetMap
  attr_accessor :planetMenu
  attr_accessor :ship
  attr_accessor :context

  def initialize args
    @context = :contextPlanetMap

    # Generate Planets
    @planets = []
    @planetSelect
    i = 0
    until i > 10 do
      @planets[i] = ObjectPlanet.new(args)
      i += 1
    end

    @ship = ObjectShip.new(args)

    # Background
    @planetMap = ContextPlanetMap.new(args)
    @planetMap.createMap(args, @planets)

    @planetMenu = ContextPlanetMenu.new(args)
  end

  def tick args

    case @context
    when :contextPlanetMap
      @planetMap.tick(args, @planets)
    when :contextPlanetMenu
      @planetMap.tick(args, @planets)
      @planetMenu.tick(args, @planetSelect)
    else
      #
    end
    
  end

  def cycle args
    for planet in @planets

      planet.cycle(args)

      #Simulate a factory
      #if planet.materials.
    end
  end
  
end