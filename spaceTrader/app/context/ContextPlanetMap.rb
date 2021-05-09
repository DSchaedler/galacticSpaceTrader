PLAYFIELD = [0, 8, 1280, 716]
# 40x22 Grid

class ContextPlanetMap < Context
  def initialize (args, stars: 150, minStarSize: 1, maxStarSize: 6, x: 0, y: 0, w: 1280, h: 720, starSaturation: 127, r: 20, g: 24, b: 46, a: 255)
    @stars = []
    until @stars.length >= stars
      randSize = randr(minStarSize, maxStarSize)

      randomColor = [randr(starSaturation, 255), 255, starSaturation]
      randomColor = randomColor.shuffle

      @stars << [randr(x, w), randr(y, h), randSize, randSize, [randomColor]]
    end

    args.outputs.static_solids << [x, y, w, h, r, g, b, a] # Draw a background color for the actual game area.
    args.outputs.static_solids << @stars

  end
  
  def tick args
    for planet in $game.sceneMain.planets
      planet.draw(args)

      if args.inputs.mouse.inside_rect? [planet.x, planet.y, 28, 28]
        args.outputs.primitives << {x: planet.x + 14, y: planet.y - 4, text:planet.name, r: 255, g:255, b:255, alignment_enum: 1, primitive_marker: :label}
        args.outputs.primitives << {x: planet.x - 2, y: planet.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',primitive_marker: :sprite}
        if args.inputs.mouse.up
          $game.sceneMain.planetSelect = planet
          $game.sceneMain.context = :contextPlanetMenu
        end
      end
    end
  end
end