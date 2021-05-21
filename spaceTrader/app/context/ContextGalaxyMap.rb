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
    
    for starSystem in systems
      @staticOutput << starSystem.draw(args)
    end
  end

  def tick (args, systems)
    @tickOutput = []
    @tickOutput << @staticOutput

    args.outputs.primitives << @tickOutput
  end
end