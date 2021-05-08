class SceneMain < Scene

  def initialize args
    # Generate Planets
    @planets = []
    @planetIndex = 0
    i = 0
    until i > 10 do
      @planets[i] = ObjectPlanet.new(args)
      i += 1
    end

    # Background
    @planetMap = ContextPlanetMap.new(args)
  end

  def setup
  end

  def tick args
    i=0
    for planet in @planets

      if args.inputs.mouse.inside_rect? [planet.x, planet.y, 28, 28]
        args.outputs.primitives << {x: planet.x + 14, y: planet.y - 4, text:planet.name, r: 255, g:255, b:255, alignment_enum: 1, primitive_marker: :label}
        args.outputs.primitives << {x: planet.x - 2, y: planet.y - 2, w: 32, h: 32, path: 'sprites/selectionCursor.png',primitive_marker: :sprite}
        planet.drawInfo(args)
      end

      for material in RESOURCES
        @planets[i].materials[material][:store] += @planets[i].materials[material][:store]
      end
      i += 1
    end
  end
  
end