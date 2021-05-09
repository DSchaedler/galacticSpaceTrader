

class Game
  attr_gtk # Magic

  attr_accessor :sceneMain

  # Runs once when game instance created
  def initialize args
    @sceneMain = SceneMain.new(args)
    @scene = :main
  end

  # Main loop
  def tick args
    args.outputs.background_color = [0, 0, 0] # Set Engine background color to black. Makes Letterboxing Black.
    @sceneMain.tick(args)

    if args.state.tick_count % 60 == 0
      cycle(args)
    end
  end

  def cycle args
    @sceneMain.cycle(args)
  end

  # Other game instance methods
end