# frozen_string_literal: true

# Runs the main scene of the game, travelling to planets and trading cargo.
class SceneMain < Scene
  attr_accessor :planets, :systems, :system_select, :planet_select, :planet_map, :planet_menu, :ship, :context

  def initialize(args)
    @context = :context_galaxy_map
    @pregeneration = false

    # Generate Planets
    @solar_systems = []
    @system_select = nil
    5.times { ; @solar_systems << ObjectSystem.new(args); }

    @ship = ObjectShip.new
    @systems = []

    # Background
    @galaxy_map = ContextGalaxyMap.new(args)
    @galaxy_map.create_map(args, @solar_systems)

    @planet_menu = ContextPlanetMenu.new(args)
  end

  def tick(args)
    pregeneration(args) if @pregeneration == false
    ui(args)

    case @context
    when :context_planet_map
      @planet_map.tick(args)
      @planet_map.check_planet_select(args)
    when :context_galaxy_map
      @planet_map.destroy_map if @planet_map
      @galaxy_map.tick(args, @solar_systems)
      @galaxy_map.check_system_select(args, @solar_systems)
    when :context_planet_menu
      @planet_map.tick(args)
      @planet_menu.tick(args)
    end
  end

  def cycle(args)
    @solar_systems.each do |cur_system|
      cur_system.system_planets.each do |planet|
        planet.cycle(args)
      end
    end
  end

  def ui(args)
    $game.draw.layers[0] << [0, 0, 1280, 720, 20, 24, 46, 255].solid # Draw a background color for the actual game area.
    status_bar(args)
  end

  def status_bar(args)
    size = 3
    height = args.gtk.calcstringbox('Sample', size)[1]
    status_bar = []

    status_bar << {
      x: 0,
      y: 0,
      w: 1280,
      h: 32,
      path: 'sprites/statusbar.png',
      primitive_marker: :sprite
    }

    status_bar << {
      x: 576,
      y: 32,
      w: 128,
      h: 32,
      path: 'sprites/statusbarJut.png',
      primitive_marker: :sprite
    }

    status_bar << {
      x: 1280 / 2,
      y: height,
      text: "Money: #{@ship.money}
| Fuel: #{@ship.materials['Fuel'][:Stored]}
| Cores: #{@ship.materials['Cores'][:Stored]}
| System: #{@galaxy_map.system_name}",
      r: 0,
      g: 0,
      b: 0,
      size_enum: size,
      alignment_enum: 1,
      primitive_marker: :label
    }

    $game.draw.layers[3] << status_bar
  end

  def pregeneration(args)
    puts 'Beginning Pregeneration...'
    50.times do
      cycle(args)
    end
    @pregeneration = true
    puts 'Pregeneration Complete.'
  end
end
