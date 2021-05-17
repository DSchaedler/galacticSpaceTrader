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
  end

  def createMap(args, planets)
    @staticOutput << [@x, @y, @w, @h, @r, @g, @b, @a].solid # Draw a background color for the actual game area.
    @staticOutput << @stars
    
    for planet in planets
      @staticOutput << planet.draw(args)
    end
  end
  
  def tick (args, planets)
    args.outputs.primitives << @staticOutput

    if $game.sceneMain.planetSelect
      planetSelect = $game.sceneMain.planetSelect

      shipFrame = args.state.tick_count.idiv(5).mod(3)
      shipDegree = args.state.tick_count.mod(360)
      distance = 60

      DEGREES_TO_RADIANS = Math::PI / 180

      posX = (distance * Math.cos(shipDegree * DEGREES_TO_RADIANS)) + planetSelect.x
      posY = distance * Math.sin(shipDegree * DEGREES_TO_RADIANS) + planetSelect.y

      args.outputs.primitives << {x: posX, y: posY, w:32, h: 32, path: "sprites/spaceship#{shipFrame}.png", angle: shipDegree, primitive_marker: :sprite}
    end

  end

  def checkPlanetSelect(args, planets)  
    for planet in planets

      if $game.sceneMain.planetSelect
        planetSelect = $game.sceneMain.planetSelect
        
        args.outputs.primitives << {x: planetSelect.x + 14, y: planetSelect.y - 4, text:planetSelect.name, r: 255, g:255, b:255, alignment_enum: 1, primitive_marker: :label}
        args.outputs.primitives << {x: planetSelect.x - 2, y: planetSelect.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',primitive_marker: :sprite}
      end

      if args.inputs.mouse.inside_rect? [planet.x, planet.y, 28, 28]
        args.outputs.primitives << {x: planet.x + 14, y: planet.y - 4, text:planet.name, r: 255, g:255, b:255, alignment_enum: 1, primitive_marker: :label}
        args.outputs.primitives << {x: planet.x - 2, y: planet.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',primitive_marker: :sprite}
        if args.inputs.mouse.up
          $game.sceneMain.planetMenu.destroyMenu(args)
          $game.sceneMain.planetSelect = planet
        end
      end

      #$game.sceneMain.planetMenu.createMenu(args, planet)
      #$game.sceneMain.context = :contextPlanetMenu
    end
  end
end