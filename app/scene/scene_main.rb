# frozen_string_literal: true

# Runs the main scene of the game, travelling to planets and trading cargo.
class SceneMain < Scene
  attr_accessor :planets, :systems, :system_select, :planet_select, :planet_map, :planet_menu, :ship, :context, :ship_inventory

  def initialize(args)
    super

    @context = :context_galaxy_map
    @pregeneration = false

    # Generate Planets
    @solar_systems = []
    @system_select = nil

    system_count = 5

    system_locations = []
    while system_locations.length < system_count

      new_system_pos = [randr(64, args.grid.right - 64), randr(64, args.grid.top - 64)]
      reject = false

      if system_locations.include? new_system_pos
        puts "#{new_system_pos} rejected: duplicate"
        reject = true
      end

      unless system_locations.empty?
        system_locations.each do |old_system_pos|
          if args.geometry.point_inside_circle? new_system_pos, old_system_pos, 128
            puts "#{new_system_pos} rejected: too close"
            reject = true
          end
        end
      end

      unless reject
        puts "New system at #{new_system_pos}"
        system_locations << new_system_pos
      end

    end

    puts system_locations

    system_locations.each do |location|
      @solar_systems << ObjectSystem.new(args, location[0], location[1])
    end

    @ship = ObjectShip.new
    @systems = []

    # Background
    @galaxy_map = ContextGalaxyMap.new(args)
    @galaxy_map.create_map(args, @solar_systems)

    @planet_menu = ContextPlanetMenu.new(args)
    @ship_inventory = ContextShipInventory.new(args)

    @event_trigger = nil
  end

  def tick(args)
    pregeneration(args) if @pregeneration == false
    ui(args)

    case @context
    when :context_planet_map
      @planet_map.tick(args)
      @planet_map.check_planet_select(args)
    when :context_galaxy_map
      @planet_map&.destroy_map(args)
      @galaxy_map.tick(args, @solar_systems)
      @galaxy_map.check_system_select(args, @solar_systems)
    when :context_planet_menu
      @planet_map.tick(args)
      @planet_menu.tick(args)
    when :context_ship_inventory
      @planet_map.tick(args)
      @ship_inventory.tick(args)
    end

    random_event(args) if args.state.tick_count.positive? && (args.state.tick_count % 18_000).zero?
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
      x: 448,
      y: 32,
      w: 128,
      h: 32,
      path: 'sprites/statusbarJut.png',
      primitive_marker: :sprite
    }
    status_bar << {
      x: 704,
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

  def random_event(args)
    event = %i[
      pirate_attack
      supply_crash
      supply_hike
      price_crash
      price_hike
    ].sample

    selected_system = @solar_systems.sample
    selected_planet = selected_system.system_planets.sample
    sample = selected_planet.materials.keys.sample
    selected_material = selected_planet.materials.select { |k, _v| k == sample }
    key = selected_material.keys[0]

    case event
    when :supply_crash
      selected_planet.materials[key][:Stored] = (selected_planet.materials[key][:Stored] * 0.8).ceil
      args.gtk.notify! "Supply of #{key} on #{selected_planet.name} in #{selected_system.name} fell 20%"
    when :supply_hike
      selected_planet.materials[key][:Stored] = (selected_planet.materials[key][:Stored] * 1.2).ceil
      args.gtk.notify! "Supply of #{key} on #{selected_planet.name} in #{selected_system.name} spiked 20%"
    when :price_crash
      selected_planet.materials[key][:Price] = (selected_planet.materials[key][:Price] * 0.8).ceil
      args.gtk.notify! "Price of #{key} on #{selected_planet.name} in #{selected_system.name} fell 20%"
    when :price_hike
      selected_planet.materials[key][:Price] = (selected_planet.materials[key][:Price] * 1.2).ceil
      args.gtk.notify! "Price of #{key} on #{selected_planet.name} in #{selected_system.name} spiked 20%"
    end
  end
end
