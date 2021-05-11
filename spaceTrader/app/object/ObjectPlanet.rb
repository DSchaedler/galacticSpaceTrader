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
    
    i = 0
    @materials = {}
    for resource in RESOURCES
      resourceInfo = {}
      resourceInfo[:rate] = randr(0.01, 1).round(2)
      resourceInfo[:stored] = 0
      resourceInfo[:price] = 1
      @materials[resource] = resourceInfo
      i += 1
    end

    @materials["Water"] = {:rate => 0, :stored => 0, :price => 1}
  end

  def cycle args
    totalStored = 0

    @materials.each {|material, values|
      totalStored += values[:stored]
    }

    if totalStored < 1000
      @materials.each {|material, values|
        values[:stored] += values[:rate]
        values[:stored] = values[:stored].round(2)
      }
    end

    consume(args, "Water", 0.01)
    consume(args, "Oxygen", 0.01)

    factory(args, [["Water", 3], ["Hydrogen", 2], ["Oxygen", 1]])
    
  end

  def consume (args, material, quantity)
    if @materials[material][:stored] >= quantity
      @materials[material][:stored] = (@materials[material][:stored] - quantity).round(2)
    else
      @materials[material][:price] = (@materials[material][:price] + (0.01 * quantity)).round(2)
    end
  end

  def factory (args, recipe) # recipe = [[product, int], [ingredient, int], [...]]
    product = recipe[0]
    recipe.shift()

    productCost = @materials[product[0]][:price] * product[1]
    
    sumCost = 0
    recipe.each { |i|
      sumCost += @materials[i[0]][:price] * i[1]
    }

    if productCost > sumCost
      # Request Materials
      haveMaterials = []
      recipe.each { |i|
        if @materials[i[0]][:stored] <= i[1] # If we don't have enough materials
          haveMaterials << false
          @materials[i[0]][:price] = (@materials[i[0]][:price] + 0.01).round(2) # Increase the price with increased deman
        else
          haveMaterials << true
        end
      }
    
      unless haveMaterials.include? false # Don't craft if we're missing materials
        recipe.each { |i|
          @materials[i[0]][:stored] = (@materials[i[0]][:stored] - i[1]).round(2)
        }
        @materials[product[0]][:stored] = (@materials[product[0]][:stored] + product[1]).round(2)
      end

    else
      recipe.each { |i|
        @materials[i[0]][:price] = (@materials[i[0]][:price] - 0.01).round(2)
      }
    end
  end

  def draw args
    return { x: @x, y: @y, w: 28, h: 28, path: @image, primitive_marker: :sprite}
  end

end