# frozen_string_literal: true

PLAYFIELD = [0, 8, 1280, 716].freeze
# 40x22 Grid

# Handles calculations and drawing of the solar system maps.
class ContextPlanetMap < Context
  def initialize(args, system_planets:, stars: 150, min_star_size: 1, max_star_size: 6, star_saturation: 127)
    # @system = system
    @planets = []
    @planets = system_planets
    @planet_select = nil

    stars.times do
      rand_size = randr(min_star_size, max_star_size)

      random_color = [randr(star_saturation, 255), 255, star_saturation]
      random_color = random_color.shuffle
      random_color.map do |color|
        color * 0.6
      end

      args.render_target(:system_stars).solids << {
        x: randr(0, 1280), y: randr(0 + 32, 720), w: rand_size, h: rand_size,
        r: random_color[0], g: random_color[1], b: random_color[2],
        a: randr(85, 255)
      }.solid!
    end

    @static_output = []

    @ship_mode = :Idle
    @ship_pos = [1280 / 2, 720 / 2]
    @fuel_ticker = 30
  end

  def create_map(args)
    @static_output << {
      x: 0, y: 0, w: args.grid.right, h: args.grid.top, path: :system_stars,
      source_x: 0, source_y: 0, source_w: args.grid.right, source_h: args.grid.top
    }

    args.render_target(:planet_map).primitives << @static_output
  end

  def destroy_map(args)
    @static_output = []
    args.render_target(:planet_map).clear_before_render = true
  end

  def tick(args)
    @system = $game.scene_main.system_select
    @planets = @system.system_planets

    $game.draw.layers[2] << { x: 0, y: 0, w: 1280, h: 720, path: :planet_map, primitive_marker: :sprite }
    @planets.each do |planet|
      $game.draw.layers[2] << planet.draw
    end

    @tick_output = []

    $game.scene_main.context = :context_galaxy_map if args.inputs.keyboard.key_up.escape && ($game.scene_main.context == :context_planet_map)

    ship_frame = args.state.tick_count.idiv(5).mod(3)

    if @planet_select && (@ship_mode == :Orbit)

      ship_degree = args.state.tick_count.mod(360)
      distance = 60

      @ship_pos[0] = (distance * Math.cos(ship_degree * DEGREES_TO_RADIANS)) + @planet_select.x
      @ship_pos[1] = (distance * Math.sin(ship_degree * DEGREES_TO_RADIANS)) + @planet_select.y

      @tick_output << { x: @ship_pos[0], y: @ship_pos[1], w: 32, h: 32, path: "sprites/spaceship#{ship_frame}.png",
                        angle: ship_degree, primitive_marker: :sprite }

      dock_button = { x: 608,
                      y: 32,
                      w: 64,
                      h: 32,
                      path: 'sprites/dockButton.png',
                      primitive_marker: :sprite }
      $game.draw.layers[3] << dock_button
      if $game.scene_main.context != :context_planet_menu && args.inputs.mouse.click && args.inputs.mouse.intersect_rect?(dock_button)
        $game.scene_main.planet_menu.create_menu(args, @planet_select)
        $game.scene_main.context = :context_planet_menu
      end

    elsif @ship_mode == :Move
      if @planet_select
        ship_degree = args.state.tick_count.mod(360)
        distance = 60

        ship_target = (distance * Math.cos(ship_degree * DEGREES_TO_RADIANS)) + @planet_select.x,
                      (distance * Math.sin(ship_degree * DEGREES_TO_RADIANS)) + @planet_select.y
        ship_degree = move_ship(args, ship_target)
        $game.scene_main.ship.materials['Fuel'][:Stored] -= 1 if (args.state.tick_count % @fuel_ticker).zero?
      end
      @tick_output << { x: @ship_pos[0], y: @ship_pos[1], w: 32, h: 32,
                        path: "sprites/spaceship#{ship_frame}.png",
                        angle: ship_degree - 90, primitive_marker: :sprite }
    elsif @ship_mode == :Idle
      @tick_output << { x: @ship_pos[0], y: @ship_pos[1], w: 32, h: 32,
                        path: "sprites/spaceship#{ship_frame}.png",
                        angle: - 90, primitive_marker: :sprite }

    end

    do_warp_button(args)
    do_inventory_button(args)

    $game.draw.layers[2] << @tick_output
  end

  def do_warp_button(args)
    warp_button = []
    warp_button << {
      x: 464, y: 32, w: 96, h: 32,
      path: 'sprites/buttonTemplate.png',
      primitive_marker: :sprite
    }
    warp_button << {
      x: 514, y: 60,
      text: 'Galaxy',
      size_enum: 3,
      alignment_enum: 1,
      primitive_marker: :label
    }

    $game.scene_main.context = :context_galaxy_map if args.inputs.mouse.up && args.inputs.mouse.inside_rect?([464, 32, 96, 32]) && ($game.scene_main.context == :context_planet_map)

    $game.draw.layers[3] << warp_button
  end

  def do_inventory_button(args)
    inventory_button = []
    inventory_button << {
      x: 704, y: 32, w: 128, h: 32,
      path: 'sprites/buttonTemplate.png',
      primitive_marker: :sprite
    }
    inventory_button << {
      x: 770, y: 60,
      text: 'Inventory',
      size_enum: 3,
      alignment_enum: 1,
      primitive_marker: :label
    }

    if $game.scene_main.context != :context_ship_inventory && args.inputs.mouse.click && args.inputs.mouse.intersect_rect?(inventory_button[0])
      $game.scene_main.ship_inventory.create_menu
      $game.scene_main.context = :context_ship_inventory
    end

    $game.draw.layers[3] << inventory_button
  end

  def move_ship(args, ship_target)
    destination = ship_target if @planet_select

    speed = 2
    distance = args.geometry.distance(@ship_pos, destination)

    ship_degree = args.geometry.angle_to(@ship_pos, destination)
    if distance > speed
      @ship_pos[0] = (speed * Math.cos(ship_degree * DEGREES_TO_RADIANS)) + @ship_pos[0]
      @ship_pos[1] = (speed * Math.sin(ship_degree * DEGREES_TO_RADIANS)) + @ship_pos[1]
    else
      @ship_pos = destination if !destination.nil? || destination != [0, 0]
      @ship_mode = :Orbit
    end

    ship_degree
  end

  def check_planet_select(args)
    select_output = []
    @planets.each do |planet|
      next unless args.inputs.mouse.inside_rect? [planet.x, planet.y, 28, 28]

      select_output << { x: planet.x + 14, y: planet.y - 4, text: planet.name, r: 255, g: 255, b: 255,
                         alignment_enum: 1, primitive_marker: :label }
      select_output << { x: planet.x - 2, y: planet.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',
                         primitive_marker: :sprite }

      next unless args.inputs.mouse.up

      $game.scene_main.planet_menu.destroy_menu(args)
      @ship_mode = :Move if planet != $game.scene_main.planet_select
      @planet_select = planet
    end

    if @planet_select

      select_output << { x: @planet_select.x + 14, y: @planet_select.y - 4,
                         text: @planet_select.name,
                         r: 255, g: 255, b: 255,
                         alignment_enum: 1, primitive_marker: :label }
      select_output << { x: @planet_select.x - 2, y: @planet_select.y - 2,
                         w: 32, h: 32, path: 'sprites/selectionCursor.png',
                         primitive_marker: :sprite }
    end

    $game.draw.layers[3] << select_output if select_output != []
  end
end
