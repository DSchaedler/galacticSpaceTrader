class SceneMain < Scene
  attr_accessor :planets
  attr_accessor :systems
  attr_accessor :systemSelect
  attr_accessor :planetSelect
  attr_accessor :planetMap
  attr_accessor :planetMenu
  attr_accessor :ship
  attr_accessor :context

  def initialize args
    @context = :contextGalaxyMap

    # Generate Planets
    @availablePlanetNames = EXOPLANET_NAMES

    @solarSystems = []
    @solarSystems << ObjectSystem.new(args, @availablePlanetNames)
    @systemSelect

    @planets = []
    @planetSelect
    i = 0
    until i > 10 do
      @planets[i] = ObjectPlanet.new(args, "PLANETNAME")
      i += 1
    end

    @ship = ObjectShip.new(args)

    @systems = []

    # Background
    @galaxyMap = ContextGalaxyMap.new(args)
    @galaxyMap.createMap(args, @solarSystems)

    @planetMap = ContextPlanetMap.new(args)
    @planetMap.createMap(args, @planets)

    @planetMenu = ContextPlanetMenu.new(args)
  end

  def tick args

    case @context
    when :contextPlanetMap
      @planetMap.tick(args, @planets)
      @planetMap.checkPlanetSelect(args, @planets)
    when :contextGalaxyMap
      args.outputs.solids << [300, 300, 50, 50, 255, 0, 0 ]
      @galaxyMap.tick(args, @solarSystems)
      @galaxyMap.checkSystemSelect(args, @solarSystems)
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