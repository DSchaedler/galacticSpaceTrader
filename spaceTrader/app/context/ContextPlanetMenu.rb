class ContextPlanetMenu < Context
  def initialize args
  end

  def tick (args, planet)
    planet.drawInfo(args)

    if args.inputs.keyboard.key_up.escape
      $game.sceneMain.context = :contextPlanetMap
    end
  end
end