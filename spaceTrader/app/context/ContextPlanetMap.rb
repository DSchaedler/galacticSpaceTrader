PLAYFIELD = [0, 8, 1280, 716]
# 40x22 Grid

class ContextPlanetMap < Context
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

  def createMap(args, planets)
    @staticOutput << [@x, @y, @w, @h, @r, @g, @b, @a].solid # Draw a background color for the actual game area.
    @staticOutput << @stars
    
    for planet in planets
      @staticOutput << planet.draw(args)
    end
  end

  def destroyMap(args)
    @staticOutput = []
  end
  
  def tick (args, planets)
    @tickOutput = []
    @tickOutput << @staticOutput

    shipFrame = args.state.tick_count.idiv(5).mod(3)

    if $game.sceneMain.planetSelect and @shipMode == :Orbit
      planetSelect = $game.sceneMain.planetSelect

      shipDegree = args.state.tick_count.mod(360)
      distance = 60

      DEGREES_TO_RADIANS = Math::PI / 180

      @shipPos[0] = (distance * Math.cos(shipDegree * DEGREES_TO_RADIANS)) + planetSelect.x
      @shipPos[1] = (distance * Math.sin(shipDegree * DEGREES_TO_RADIANS)) + planetSelect.y

      @tickOutput << {x: @shipPos[0], y: @shipPos[1], w:32, h: 32, path: "sprites/spaceship#{shipFrame}.png", angle: shipDegree, primitive_marker: :sprite}

      dockButton = {x: args.grid.w - 64, y: args.grid.h - 32, w: 64, h: 32, path: "sprites/dockButton.png", primitive_marker: :sprite}
      @tickOutput << dockButton
      if args.inputs.mouse.click and args.inputs.mouse.intersect_rect? dockButton
        $game.sceneMain.planetMenu.createMenu(args, planetSelect)
        $game.sceneMain.context = :contextPlanetMenu
      end

    elsif @shipMode = :Move
      if $game.sceneMain.planetSelect
        planetSelect = $game.sceneMain.planetSelect
        shipDegree = args.state.tick_count.mod(360)
        distance = 60
        DEGREES_TO_RADIANS = Math::PI / 180
      
        shipTarget = (distance * Math.cos(shipDegree * DEGREES_TO_RADIANS)) + planetSelect.x, (distance * Math.sin(shipDegree * DEGREES_TO_RADIANS)) + planetSelect.y
        shipDegree = moveShip(args, shipTarget)
      end
      @tickOutput << args.outputs.primitives << {x: @shipPos[0], y: @shipPos[1], w:32, h: 32, path: "sprites/spaceship#{shipFrame}.png", angle: shipDegree - 90, primitive_marker: :sprite}
    end

    args.outputs.primitives << @tickOutput
  end

  def moveShip(args, shipTarget)
    
    if $game.sceneMain.planetSelect
      planetSelect = $game.sceneMain.planetSelect
      destination = shipTarget
    end

    speed = 2
    distance = args.geometry.distance(@shipPos, destination)

    if distance > speed
      shipDegree = args.geometry.angle_to(@shipPos, destination)
      DEGREES_TO_RADIANS = Math::PI / 180
      @shipPos[0] = (speed * Math.cos(shipDegree * DEGREES_TO_RADIANS)) + @shipPos[0]
      @shipPos[1] = (speed * Math.sin(shipDegree * DEGREES_TO_RADIANS)) + @shipPos[1]
    else
      shipDegree = args.geometry.angle_to(@shipPos, destination)
      @shipPos = destination
      @shipMode = :Orbit
    end

    return shipDegree
  end

  def checkPlanetSelect(args, planets)  
    selectOutput = []
    for planet in planets

      if $game.sceneMain.planetSelect
        planetSelect = $game.sceneMain.planetSelect
        
        selectOutput << {x: planetSelect.x + 14, y: planetSelect.y - 4, text:planetSelect.name, r: 255, g:255, b:255, alignment_enum: 1, primitive_marker: :label}
        selectOutput << {x: planetSelect.x - 2, y: planetSelect.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',primitive_marker: :sprite}
      end

      if args.inputs.mouse.inside_rect? [planet.x, planet.y, 28, 28]
        selectOutput << {x: planet.x + 14, y: planet.y - 4, text:planet.name, r: 255, g:255, b:255, alignment_enum: 1, primitive_marker: :label}
        selectOutput << {x: planet.x - 2, y: planet.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',primitive_marker: :sprite}
        if args.inputs.mouse.up
          $game.sceneMain.planetMenu.destroyMenu(args)
          if planet != $game.sceneMain.planetSelect
            @shipMode = :Move
          end
          $game.sceneMain.planetSelect = planet
        end
      end

      

      #$game.sceneMain.planetMenu.createMenu(args, planet)
      #$game.sceneMain.context = :contextPlanetMenu
    end

    args.outputs.primitives << selectOutput
  end
end