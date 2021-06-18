class Game
  attr_gtk # Magic

  attr_accessor :sceneMain

  # Runs once when game instance created
  def initialize args
    @pregeneration = false
    @sceneMain = SceneMain.new(args)
    @scene = :main
  end

  # Main loop
  def tick(args)
    if @pregeneration == false
      200.times do
        @sceneMain.cycle(args)
      end
      @pregeneration = true
    end
    args.outputs.background_color = [0, 0, 0] # Set Engine background color to black. Makes Letterboxing Black.
    @sceneMain.tick(args)

    return unless (args.state.tick_count % 60).zero?

    cycle(args)
  end

  def cycle args
    @sceneMain.cycle(args)
  end

  # Other game instance methods
end
