class Background
  def initialize (stars:, maxStarSize:, minX:, minY:, maxX: 1280, maxY: 720)
    @stars = []
    until @stars.length >= stars
      randSize = randr(1, maxStarSize)
      @stars << [randr(minX, maxX), randr(minY, maxY), randSize, randSize, 255, 255, 255] # Magic Number - Stars are always white. Fuck you, that's why.
    end
  end

  def drawBackground (args, r:, g:, b:, a: 255)
    args.outputs.background_color = [0, 0, 0] # Set Engine background color to black. Makes Letterboxing Black.
    args.outputs.solids << [0, 0, args.grid.w, args.grid.h, r, g, b, a] # Draw a background color for the actual game area.
    args.outputs.solids << @stars
  end
end