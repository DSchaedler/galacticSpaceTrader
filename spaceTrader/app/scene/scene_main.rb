# frozen_string_literal: true

# Runs the main scene of the game, travelling to planets and trading cargo.
class SceneMain < Scene
  attr_accessor :planets
  attr_accessor :systems
  attr_accessor :system_select
  attr_accessor :planet_select
  attr_accessor :planet_map
  attr_accessor :planet_menu
  attr_accessor :ship
  attr_accessor :context

  def initialize(args)
    @context = :context_galaxy_map

    # Generate Planets
    @solar_systems = []
    @system_select = nil
    5.times { ; @solar_systems << ObjectSystem.new(args); }

    @ship = ObjectShip.new(args)

    @systems = []

    # Background
    @galaxy_map = ContextGalaxyMap.new(args)
    @galaxy_map.create_map(args, @solar_systems)

    @planet_menu = ContextPlanetMenu.new(args)
  end

  def tick(args)
    case @context
    when :context_planet_map
      @planet_map.tick(args)
      @planet_map.checkPlanetSelect(args)
    when :context_galaxy_map
      @planet_map&.destroyMap()
      @galaxy_map.tick(args, @solar_systems)
      @galaxy_map.check_system_select(args, @solar_systems)
    when :context_planet_menu
      @planet_map.tick(args)
      @planet_menu.tick(args)
    end

    size = 3
    height = args.gtk.calcstringbox('Sample', size)[1]
    status_bar = {
      x: 1280 / 2,
      y: height,
      text: "Money: #{@ship.money} | Fuel: #{@ship.materials['Fuel'][:Stored]} | Cores: #{@ship.cores} | System: #{@galaxy_map.system_name}", # rubocop:disable Layout/LineLength
      r: 0,
      g: 255,
      b: 0,
      size_enum: size,
      alignment_enum: 1,
      primitive_marker: :label
    }

    args.outputs.primitives << status_bar
  end

  def cycle(args)
    @solar_systems.each do |cur_system|
      cur_system.systemPlanets.each do |planet|
        planet.cycle(args)
      end
    end
  end
end
