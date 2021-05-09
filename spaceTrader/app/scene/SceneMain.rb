class SceneMain < Scene
  attr_accessor :planets
  attr_accessor :planetSelect
  attr_accessor :context

  def initialize args
    @context = :contextPlanetMap

    # Generate Planets
    @planets = []
    @planetSelect
    i = 0
    until i > 10 do
      @planets[i] = ObjectPlanet.new(args)
      i += 1
    end

    # Background
    @planetMap = ContextPlanetMap.new(args)

    @planetMenu = ContextPlanetMenu.new(args)
  end

  def tick args

    case @context
    when :contextPlanetMap
      @planetMap.tick(args)
    when :contextPlanetMenu
      @planetMenu.tick(args, @planetSelect)
    else
      #
    end
    
  end

  def cycle args
    for planet in @planets
      totalStored = 0
      planet.materials = planet.materials.sort_by { |k| -k[:stored]}

      m = 0
      for i in planet.materials
        totalStored += planet.materials[m][:stored]
        m += 1
      end
      if totalStored < 1000
        m = 0
        for i in planet.materials
          planet.materials[m][:stored] += planet.materials[m][:rate]
          planet.materials[m][:stored] = planet.materials[m][:stored].round(2)
          m += 1
        end
      end
    end
  end
  
end