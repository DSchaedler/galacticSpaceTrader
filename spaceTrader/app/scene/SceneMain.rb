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
    @systemSelect
    5.times do
      @solarSystems << ObjectSystem.new(args, @availablePlanetNames)
    end

    @ship = ObjectShip.new(args)

    @systems = []

    # Background
    @galaxyMap = ContextGalaxyMap.new(args)
    @galaxyMap.createMap(args, @solarSystems)

    @planetMenu = ContextPlanetMenu.new(args)
  end

  def tick args

    case @context
    when :contextPlanetMap
      @planetMap.tick(args)
      @planetMap.checkPlanetSelect(args)
    when :contextGalaxyMap
      if @planetMap
        @planetMap.destroyMap(args)
      end
      args.outputs.solids << [300, 300, 50, 50, 255, 0, 0 ]
      @galaxyMap.tick(args, @solarSystems)
      @galaxyMap.checkSystemSelect(args, @solarSystems)
    when :contextPlanetMenu
      @planetMap.tick(args)
      @planetMenu.tick(args, @planetSelect)
    else
      #
    end
  end

  def cycle args
    if @systemSelect #TODO update all systems at once, or only update when on planet and interpolate data.
      for planet in @systemSelect.systemPlanets
        planet.cycle(args)
      end
    end
  end
  
end