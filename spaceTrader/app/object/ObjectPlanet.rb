class ObjectPlanet < Object

  # Creates attribute accessors for instance variables.
  # Just pretend that you have to declare instance variables and it will be fine.
  attr_accessor :x
  attr_accessor :y
  attr_accessor :type
  attr_accessor :name
  attr_accessor :image
  attr_accessor :materials

  def initialize args
    # Generate unique planet information
    @x = randr(1, 38) * 32
    @y = randr(1, 21) * 32
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
  end

  def draw args
    args.outputs.primitives << { x: @x, y: @y, w: 28, h: 28, path: @image, primitive_marker: :sprite}
  end

  def drawInfo (args, originX: args.grid.left, originY: args.grid.top)
    # No information should be calculated here. Only interface elements

    elementPadding = 10

    # Stuff for calculating the width of the column
    manganeseWidth = args.gtk.calcstringbox("Manganese")[0] # This is the longest element name
    storedAmountWidth = args.gtk.calcstringbox("0000.00")[0] # This is the maximum amount of a single material

    imageWidth = manganeseWidth + storedAmountWidth
    imageHeight = imageWidth
    
    # Textbox Sprite 
    textboxBackground(args, x: 0, y: args.grid.top, w: imageWidth + elementPadding * 2, h: args.grid.h)
    # Planet Sprite
    args.outputs.primitives << { x: originX + elementPadding, y: originY - imageHeight - elementPadding, w: imageWidth, h: imageHeight, path: @image, primitive_marker: :sprite}

    #Labels
    sampleStringHeight = args.gtk.calcstringbox(@name)[1]
    args.outputs.primitives << { x: originX + elementPadding, y: args.grid.top - imageHeight - elementPadding - ( sampleStringHeight * 1 ), text: @name, primitive_marker: :label}
    args.outputs.primitives << { x: originX + elementPadding, y: args.grid.top - imageHeight - elementPadding - ( sampleStringHeight * 2 ), text: @type, primitive_marker: :label}

    printIndex = 0
    listStart = args.grid.top - imageHeight - ( sampleStringHeight * 4 )
    for i in RESOURCES
      args.outputs.primitives << {x: args.grid.left + elementPadding , y: listStart - ( sampleStringHeight * printIndex ), text: "#{i}", primitive_marker: :label} #RESOURCE NAME
      args.outputs.primitives << {x: args.grid.left + manganeseWidth + storedAmountWidth, y: listStart - ( sampleStringHeight * printIndex), text: @materials[i][:stored], primitive_marker: :label} #RESOURCE STORED
      printIndex += 1
    end
  end
end