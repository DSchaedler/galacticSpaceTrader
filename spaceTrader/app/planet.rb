class Planet
  # Creates attribute accessors for instance variables.
  # Just pretend that you have to declare instance variables and it will be fine.
  attr_accessor :type
  attr_accessor :name
  attr_accessor :image
  attr_accessor :materials

  def initialize
    # Generate unique planet information
    @type = PLANET_TYPE_STRINGS.sample()
    @name = EXOPLANET_NAMES.sample()

    # Randomly determine which planet image we should use.
    if @type == "Inferno" || "Toxic" # These two have fewer images available, so we treat them specially.
      @image = "sprites/PixelPlanets/#{@type.downcase}#{randr(0, 3)}.png"
    else
      @image = "sprites/PixelPlanets/#{@type.downcase}#{randr(0, 5)}.png"
    end

    @materials = {}
    for i in RESOURCES
      resourceInfo = {}
      resourceInfo[:rate] = randr(0.01, 1).round(2)
      resourceInfo[:stored] = 0
      @materials[i] = resourceInfo
    end
    puts @materials

  end
end