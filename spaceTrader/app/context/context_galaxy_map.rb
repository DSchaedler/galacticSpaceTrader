# frozen_string_literal: true

class ContextGalaxyMap < Context
  attr_accessor :currentSystem
  attr_accessor :systemName

  def initialize(args, stars: 600, minStarSize: 1, maxStarSize: 6, starSaturation: 127)
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
      randSize = randr(minStarSize, maxStarSize)

      randomColor = [randr(starSaturation, 255), 255, starSaturation]
      randomColor = randomColor.shuffle
      point = gaussian(0.5, 0.2)

      @stars << { x: point[0] * 1280, y: point[1] * 720, w: randSize, h: randSize, r: randomColor[0], g: randomColor[1], b: randomColor[2] }.solid
    end

    @staticOutput = []

    @shipMode = :Orbit
    @shipPos = [args.grid.center.w / 2, args.grid.center.h / 2]
    @burnCore = false
    @currentSystem = nil
    @systemName = ''
  end

  def createMap(args, systems)
    @staticOutput << [@x, @y, @w, @h, @r, @g, @b, @a].solid # Draw a background color for the actual game area.
    @staticOutput << @stars

    systemsArray = []
    systems.each do |starSystem|
      location = starSystem.draw(args)
      sprite = { x: location[0], y: location[1], w: 28, h: 28, path: 'sprites/PixelPlanets/shadowmap0.png', r: randr(0, 255), g: randr(0, 255), b: randr(0, 255), primitive_marker: :sprite }
      @staticOutput << sprite
    end
    @staticOutput << systemsArray
  end

  def tick(args, _systems)
    @tickOutput = []
    @tickOutput << @staticOutput

    args.outputs.primitives << @tickOutput
  end

  def check_system_select(args, systems)
    selectOutput = []
    systems.each do |eachSystem|
      if $game.scene_main.system_select
        system_select = $game.scene_main.system_select

        selectOutput << { x: system_select.x + 14, y: system_select.y - 4, text: system_select.name, r: 255, g: 255, b: 255, alignment_enum: 1, primitive_marker: :label }
        selectOutput << { x: system_select.x - 2, y: system_select.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png', primitive_marker: :sprite }
      end

      next unless args.inputs.mouse.inside_rect? [eachSystem.x, eachSystem.y, 28, 28]

      selectOutput << { x: eachSystem.x + 14, y: eachSystem.y - 4, text: eachSystem.name, r: 255, g: 255, b: 255, alignment_enum: 1, primitive_marker: :label }
      selectOutput << { x: eachSystem.x - 2, y: eachSystem.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png', primitive_marker: :sprite }
      $game.scene_main.system_select = eachSystem if args.inputs.mouse.up
    end

    if $game.scene_main.system_select

      dockButton = []
      dockButton << { x: args.grid.w - 64, y: args.grid.h - 32, w: 64, h: 32, path: 'sprites/buttonTemplate.png', primitive_marker: :sprite }
      dockButton << { x: args.grid.w - 30, y: args.grid.h - 2, text: 'Warp', size_enum: 3, alignment_enum: 1, primitive_marker: :label }

      selectOutput << dockButton
      if args.inputs.mouse.click && args.inputs.mouse.intersect_rect?(dockButton[0])
        if $game.scene_main.system_select != @currentSystem
          @currentSystem = $game.scene_main.system_select
          @systemName = @currentSystem.name
          $game.scene_main.ship.cores -= 1
        end
        $game.scene_main.planetMap = ContextPlanetMap.new
        $game.scene_main.planetMap.createMap(args)
        $game.scene_main.context = :contextPlanetMap
      end
    end

    args.outputs.primitives << selectOutput
  end
end
