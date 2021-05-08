class ContextPlanetMap < Context
  def initialize (args, stars: 150, minStarSize: 1, maxStarSize: 6, x: 0, y: 0, w: 1280, h: 720, starSaturation: 127, r: 20, g: 24, b: 46, a: 255)
    @stars = []
    until @stars.length >= stars
      randSize = randr(minStarSize, maxStarSize)

      randomColor = [randr(starSaturation, 255), 255, starSaturation]
      randomColor = randomColor.shuffle

      @stars << [randr(x, w), randr(y, h), randSize, randSize, [randomColor]]
    end

    args.outputs.background_color = [0, 0, 0] # Set Engine background color to black. Makes Letterboxing Black.
    args.outputs.static_solids << [x, y, w, h, r, g, b, a] # Draw a background color for the actual game area.
    args.outputs.static_solids << @stars

  end
end