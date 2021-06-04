class ContextGalaxyMap < Context

  def initialize (args, stars: 150, minStarSize: 1, maxStarSize: 6, x: 0, y: 0, w: 1280, h: 720, starSaturation: 127, r: 20, g: 24, b: 46, a: 255)
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

      @stars << {x: randr(x, w), y: randr(y, h), w: randSize, h: randSize, r: randomColor[0], g: randomColor[1], b: randomColor[2]}.solid
    end

    @staticOutput = []

    @shipMode = :Orbit
    @shipPos = [args.grid.center.w / 2, args.grid.center.h / 2]
  end

  def createMap(args, systems)
    @staticOutput << [@x, @y, @w, @h, @r, @g, @b, @a].solid # Draw a background color for the actual game area.
    @staticOutput << @stars
    
    systemsArray = []
    for starSystem in systems
      location = starSystem.draw(args)
      sprite = {x: location[0], y: location[1], w: 28, h: 28, path: "sprites/PixelPlanets/shadowmap0.png", r: randr(0, 255), g: randr(0, 255), b: randr(0, 255), primitive_marker: :sprite}
      @staticOutput << sprite
    end
    puts @staticOutput
    @staticOutput << systemsArray
  end

  def tick (args, systems)
    @tickOutput = []
    @tickOutput << @staticOutput

    args.outputs.primitives << @tickOutput
  end

  def checkSystemSelect(args, systems)  
    selectOutput = []
    for eachSystem in systems

      if $game.sceneMain.systemSelect
        systemSelect = $game.sceneMain.systemSelect
        
        selectOutput << {x: systemSelect.x + 14, y: systemSelect.y - 4, text:systemSelect.name, r: 255, g:255, b:255, alignment_enum: 1, primitive_marker: :label}
        selectOutput << {x: systemSelect.x - 2, y: systemSelect.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',primitive_marker: :sprite}

        dockButton = {x: args.grid.w - 64, y: args.grid.h - 32, w: 64, h: 32, path: "sprites/dockButton.png", primitive_marker: :sprite}
        selectOutput << dockButton
        if args.inputs.mouse.click and args.inputs.mouse.intersect_rect? dockButton
          $game.sceneMain.planetMap = ContextPlanetMap.new(args)
          $game.sceneMain.planetMap.createMap(args)
          $game.sceneMain.context = :contextPlanetMap
        end
      end

      if args.inputs.mouse.inside_rect? [eachSystem.x, eachSystem.y, 28, 28]
        selectOutput << {x: eachSystem.x + 14, y: eachSystem.y - 4, text:eachSystem.name, r: 255, g:255, b:255, alignment_enum: 1, primitive_marker: :label}
        selectOutput << {x: eachSystem.x - 2, y: eachSystem.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',primitive_marker: :sprite}
        if args.inputs.mouse.up
          $game.sceneMain.systemSelect = eachSystem
        end
      end
      
    end

    args.outputs.primitives << selectOutput
  end
end