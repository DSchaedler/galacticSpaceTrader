# frozen_string_literal: true

PLAYFIELD = [0, 8, 1280, 716].freeze
# 40x22 Grid

# Handles calculations and drawing of the solar system maps.
class ContextPlanetMap < Context
  def initialize(stars: 150, minStarSize: 1, maxStarSize: 6, x: 0, y: 0, w: 1280, h: 720, starSaturation: 127, r: 20, g: 24, b: 46, a: 255)
    @x = x
    @y = y
    @w = w
    @h = h
    @r = r
    @g = g
    @b = b
    @a = a

    @system = $game.scene_main.system_select
    @planets = []
    @planets = @system.systemPlanets
    @planetSelect = nil

    @stars = []
    until @stars.length >= stars
      randSize = randr(minStarSize, maxStarSize)

      randomColor = [randr(starSaturation, 255), 255, starSaturation]
      randomColor = randomColor.shuffle

      @stars << { x: randr(x, w), y: randr(y, h), w: randSize, h: randSize, r: randomColor[0], g: randomColor[1], b: randomColor[2] }.solid
    end

    @staticOutput = []

    @shipMode = :Orbit
    @shipPos = [1280 / 2, 720 / 2]
  end

  def create_map(args)
    @staticOutput << [@x, @y, @w, @h, @r, @g, @b, @a].solid # Draw a background color for the actual game area.
    @staticOutput << @stars

    @planets.each do |planet|
      @staticOutput << planet.draw(args)
    end
  end

  def destroyMap
    @staticOutput = []
  end

  def tick(args)
    @system = $game.scene_main.system_select
    @planets = @system.systemPlanets

    @tickOutput = []
    @tickOutput << @staticOutput

    if args.inputs.keyboard.key_up.escape
      $game.scene_main.context = :contextGalaxyMap if $game.scene_main.context == :contextPlanetMap
    end

    shipFrame = args.state.tick_count.idiv(5).mod(3)

    if @planetSelect && (@shipMode == :Orbit)

      shipDegree = args.state.tick_count.mod(360)
      distance = 60

      @shipPos[0] = (distance * Math.cos(shipDegree * DEGREES_TO_RADIANS)) + @planetSelect.x
      @shipPos[1] = (distance * Math.sin(shipDegree * DEGREES_TO_RADIANS)) + @planetSelect.y

      @tickOutput << { x: @shipPos[0], y: @shipPos[1], w: 32, h: 32, path: "sprites/spaceship#{shipFrame}.png", angle: shipDegree, primitive_marker: :sprite }

      dockButton = { x: args.grid.w - 64, y: args.grid.h - 32, w: 64, h: 32, path: 'sprites/dockButton.png', primitive_marker: :sprite }
      @tickOutput << dockButton
      if args.inputs.mouse.click && args.inputs.mouse.intersect_rect?(dockButton)
        puts @planetSelect
        $game.scene_main.planet_menu.create_menu(@planetSelect)
        $game.scene_main.context = :context_planet_menu
      end

    elsif @shipMode == :Move
      if @planetSelect
        shipDegree = args.state.tick_count.mod(360)
        distance = 60

        shipTarget = (distance * Math.cos(shipDegree * DEGREES_TO_RADIANS)) + @planetSelect.x, (distance * Math.sin(shipDegree * DEGREES_TO_RADIANS)) + @planetSelect.y
        shipDegree = moveShip(args, shipTarget)
        $game.scene_main.ship.materials['Fuel'][:Stored] -= 0.01
        $game.scene_main.ship.materials['Fuel'][:Stored] = $game.scene_main.ship.materials['Fuel'][:Stored].round(2)
      end
      @tickOutput << args.outputs.primitives << { x: @shipPos[0], y: @shipPos[1], w: 32, h: 32, path: "sprites/spaceship#{shipFrame}.png", angle: shipDegree - 90, primitive_marker: :sprite }
    end

    args.outputs.primitives << @tickOutput
  end

  def moveShip(args, shipTarget)
    destination = shipTarget if @planetSelect

    speed = 2
    distance = args.geometry.distance(@shipPos, destination)

    if distance > speed
      shipDegree = args.geometry.angle_to(@shipPos, destination)
      @shipPos[0] = (speed * Math.cos(shipDegree * DEGREES_TO_RADIANS)) + @shipPos[0]
      @shipPos[1] = (speed * Math.sin(shipDegree * DEGREES_TO_RADIANS)) + @shipPos[1]
    else
      shipDegree = args.geometry.angle_to(@shipPos, destination)
      @shipPos = destination if !destination.nil? || destination != [0, 0]
      @shipMode = :Orbit
    end

    shipDegree
  end

  def checkPlanetSelect(args)
    selectOutput = []
    @planets.each do |planet|
      if @planetSelect

        selectOutput << { x: @planetSelect.x + 14, y: @planetSelect.y - 4, text: @planetSelect.name, r: 255, g: 255, b: 255, alignment_enum: 1, primitive_marker: :label }
        selectOutput << { x: @planetSelect.x - 2, y: @planetSelect.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png', primitive_marker: :sprite }
      end

      next unless args.inputs.mouse.inside_rect? [planet.x, planet.y, 28, 28]

      selectOutput << { x: planet.x + 14, y: planet.y - 4, text: planet.name, r: 255, g: 255, b: 255, alignment_enum: 1, primitive_marker: :label }
      selectOutput << { x: planet.x - 2, y: planet.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png', primitive_marker: :sprite }
      next unless args.inputs.mouse.up

      $game.scene_main.planet_menu.destroyMenu
      @shipMode = :Move if planet != $game.scene_main.planet_select
      @planetSelect = planet
    end

    args.outputs.primitives << selectOutput
  end
end
