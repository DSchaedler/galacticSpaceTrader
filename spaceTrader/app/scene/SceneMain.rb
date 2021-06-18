# frozen_string_literal: true

class SceneMain < Scene
  attr_accessor :planets
  attr_accessor :systems
  attr_accessor :systemSelect
  attr_accessor :planetSelect
  attr_accessor :planetMap
  attr_accessor :planetMenu
  attr_accessor :ship
  attr_accessor :context

  def initialize(args)
    @context = :contextGalaxyMap

    # Generate Planets

    @solarSystems = []
    @systemSelect
    5.times do
      @solarSystems << ObjectSystem.new(args)
    end

    @ship = ObjectShip.new(args)

    @systems = []

    # Background
    @galaxyMap = ContextGalaxyMap.new(args)
    @galaxyMap.createMap(args, @solarSystems)

    @planetMenu = ContextPlanetMenu.new(args)
  end

  def tick(args)
    case @context
    when :contextPlanetMap
      @planetMap.tick(args)
      @planetMap.checkPlanetSelect(args)
    when :contextGalaxyMap
      @planetMap&.destroyMap(args)
      @galaxyMap.tick(args, @solarSystems)
      @galaxyMap.checkSystemSelect(args, @solarSystems)
    when :contextPlanetMenu
      @planetMap.tick(args)
      @planetMenu.tick(args)
    end

    ship = $game.sceneMain.ship
    size = 3
    height = args.gtk.calcstringbox('Sample', size)[1]
    statusBar = {
      x: 1280 / 2,
      y: height,
      text: "Money: #{ship.money} | Fuel: #{ship.materials['Fuel'][:Stored]} | Cores: #{ship.cores} | System: #{@galaxyMap.systemName}",
      r: 0,
      g: 255,
      b: 0,
      size_enum: size,
      alignment_enum: 1,
      primitive_marker: :label
    }

    args.outputs.primitives << statusBar
  end

  def cycle(args)
    @solarSystems.each do |curSystem| # TODO: update all systems at once, or only update when on planet and interpolate data.
      curSystem.systemPlanets.each do |planet|
        planet.cycle(args)
      end
    end
  end
end
