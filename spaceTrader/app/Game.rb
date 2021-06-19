# frozen_string_literal: true

# The core game loop runs here.
class Game
  attr_gtk # Magic

  attr_accessor :scene_main

  # Runs once when game instance created
  def initialize(args)
    @pregeneration = false
    @scene_main = SceneMain.new(args)
    @scene = :main
  end

  # Main loop
  def tick(args)
    if @pregeneration == false
      200.times do
        @scene_main.cycle(args)
      end
      @pregeneration = true
    end
    args.outputs.background_color = [0, 0, 0] # Set Engine background color to black. Makes Letterboxing Black.
    @scene_main.tick(args)

    return unless (args.state.tick_count % 60).zero?

    cycle(args)
  end

  def cycle(args)
    @scene_main.cycle(args)
  end

  # Other game instance methods
end
