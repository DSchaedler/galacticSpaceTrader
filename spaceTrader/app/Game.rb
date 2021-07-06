# frozen_string_literal: true

# The core game loop runs here.
class Game
  attr_gtk # Magic

  attr_accessor :scene_main

  # Runs once when game instance created
  def initialize(args)
    @scene_main = SceneMain.new(args)
    @scene = :main
  end

  # Main loop
  def tick(args)
    args.outputs.background_color = [0, 0, 0] # Set Engine background color to black. Makes Letterboxing Black.
    @scene_main.tick(args)

    cycle(args) if (args.state.tick_count % 60).zero?

    return unless args.inputs.keyboard.key_up.delete

    puts '[Screenshot Saving]'
    system_time = Time.new.to_i
    args.outputs.screenshots << { x: 0, y: 0, w: 1280, h: 720, path: "#{system_time}.png" }
  end

  def cycle(args)
    @scene_main.cycle(args)
  end

  # Other game instance methods
end
