# frozen_string_literal: true

# Handles calculations and drawing of the galaxy map.
class ContextGalaxyMap < Context
  attr_accessor :current_system, :system_name

  def initialize(args, stars: 600, min_star_size: 1, max_star_size: 6, star_saturation: 127)
    @x = 0
    @y = 0
    @w = args.grid.w
    @h = args.grid.h
    @r = 20
    @g = 24
    @b = 46
    @a = 255

    @stars = []
    until @stars.length >= stars
      rand_size = randr(min_star_size, max_star_size)

      random_color = [randr(star_saturation, 255), 255, star_saturation]
      random_color = random_color.shuffle
      point = gaussian(0.5, 0.2)

      @stars << [point[0] * 1280,
                  point[1] * 720 + 32,
                  rand_size,
                  rand_size,
                  random_color[0],
                  random_color[1],
                  random_color[2] ]
    end
    @stars.each do |i|
      args.render_target(:galaxy_stars).solids << i
    end

    @static_output = []

    @ship_mode = :Orbit
    @ship_pos = [args.grid.center.w / 2, args.grid.center.h / 2]
    @burn_core = false
    @current_system = nil
    @system_name = ''
    @render_stars = false
  end

  def render_stars(args)
  end

  def create_map(args, systems)
    @static_output << {
      x: 0, y: 0, w: args.grid.right, h: args.grid.top, path: :galaxy_stars,
      source_x: 0, source_y: 0, source_w: args.grid.right, source_h: args.grid.top
    }

    systems_array = []
    systems.each do |star_system|
      location = star_system.draw(args)
      sprite = { x: location[0],
                 y: location[1],
                 w: 28,
                 h: 28,
                 path: 'sprites/PixelPlanets/shadowmap0.png',
                 r: randr(0, 255),
                 g: randr(0, 255),
                 b: randr(0, 255),
                 primitive_marker: :sprite }
      @static_output << sprite
    end
    @static_output << systems_array
  end

  def tick(args, _systems)
    @tick_output = []
    @tick_output << @static_output

    args.outputs.primitives << @tick_output
  end

  def check_system_select(args, systems)
    select_output = []
    systems.each do |each_system|
      if $game.scene_main.system_select
        system_select = $game.scene_main.system_select

        select_output << { x: system_select.x + 14,
                           y: system_select.y - 4,
                           text: system_select.name,
                           r: 255,
                           g: 255,
                           b: 255,
                           alignment_enum: 1,
                           primitive_marker: :label }
        select_output << { x: system_select.x - 2,
                           y: system_select.y - 2,
                           w: 32,
                           h: 32,
                           path: 'sprites/selectionCursor.png',
                           primitive_marker: :sprite }
      end

      next unless args.inputs.mouse.inside_rect? [each_system.x, each_system.y, 28, 28]

      select_output << { x: each_system.x + 14,
                         y: each_system.y - 4,
                         text: each_system.name,
                         r: 255,
                         g: 255,
                         b: 255,
                         alignment_enum: 1,
                         primitive_marker: :label }
      select_output << { x: each_system.x - 2,
                         y: each_system.y - 2,
                         w: 32,
                         h: 32,
                         path: 'sprites/selectionCursor.png',
                         primitive_marker: :sprite }
      $game.scene_main.system_select = each_system if args.inputs.mouse.up
    end

    if $game.scene_main.system_select

      dock_button = []
      dock_button << { x: 608,
                       y: 32,
                       w: 64,
                       h: 32,
                       path: 'sprites/buttonTemplate.png',
                       primitive_marker: :sprite }
      dock_button << { x: 642,
                       y: 60,
                       text: 'Warp',
                       size_enum: 3,
                       alignment_enum: 1,
                       primitive_marker: :label }

      select_output << dock_button
      if args.inputs.mouse.click && args.inputs.mouse.intersect_rect?(dock_button[0])
        if $game.scene_main.system_select != @current_system
          @current_system = $game.scene_main.system_select
          @system_name = @current_system.name
          $game.scene_main.ship.materials['Cores'][:Stored] -= 1
        end
        $game.scene_main.planet_map = @current_system.star_map
        $game.scene_main.planet_map.create_map(args)
        $game.scene_main.context = :context_planet_map
      end
    end

    args.outputs.primitives << select_output
  end
end
