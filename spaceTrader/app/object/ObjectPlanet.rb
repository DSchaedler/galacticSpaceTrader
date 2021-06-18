# frozen_string_literal: true

class ObjectPlanet < Object
  # Creates attribute accessors for instance variables.
  # Just pretend that you have to declare instance variables and it will be fine.
  attr_accessor :x
  attr_accessor :y
  attr_accessor :type
  attr_accessor :name
  attr_accessor :image
  attr_accessor :materials

  def initialize(_args, planetName)
    # Generate unique planet information
    @x = randr(1, 38) * 32
    @y = randr(1, 21) * 32
    @type = PLANET_TYPE_STRINGS.sample
    @name = planetName

    # Randomly determine which planet image we should use.
    @image = if @type == 'Inferno' || 'Toxic' # These two have fewer images available, so we treat them specially.
               "sprites/PixelPlanets/#{@type.downcase}#{randr(0, 3)}.png"
             else
               "sprites/PixelPlanets/#{@type.downcase}#{randr(0, 5)}.png"
             end

    i = 0
    @materials = {}
    RESOURCES.each do |resource|
      resourceInfo = {}
      resourceInfo[:Rate] = randr(0.01, 1).round(2)
      resourceInfo[:Stored] = 0
      resourceInfo[:Price] = 10
      @materials[resource] = resourceInfo
      i += 1
    end

    @materials['Water'] = { Rate: 0, Stored: 0, Price: 10 }
    @materials['Fuel'] = { Rate: 0, Stored: 0, Price: 10 }
  end

  def cycle(args)
    totalStored = 0

    @materials.each do |_material, values|
      totalStored += values[:Stored]
    end

    if totalStored < 1000
      @materials.each do |_material, values|
        values[:Stored] += values[:Rate]
        values[:Stored] = values[:Stored].round(2)
        if (values[:Rate]).positive?
          values[:Price] -= 0.01
          values[:Price] = values[:Price].round(2)
        end
      end
    end

    consume(args, 'Water', 0.01)
    consume(args, 'Oxygen', 0.01)

    factory(args, [['Water', 3], ['Hydrogen', 2], ['Oxygen', 1]])
    factory(args, [['Fuel', 5], ['Hydrogen', 1], ['Oxygen', 4]])
  end

  def consume(_args, material, quantity)
    if @materials[material][:Stored] >= quantity
      @materials[material][:Stored] = (@materials[material][:Stored] - quantity).round(2)
    else
      @materials[material][:Price] = (@materials[material][:Price] + (0.01 * quantity)).round(2)
    end
  end

  def factory(_args, recipe) # recipe = [[product, int], [ingredient, int], [...]]
    product = recipe[0]
    recipe.shift

    productCost = @materials[product[0]][:Price] * product[1]

    sumCost = 0
    recipe.each do |i|
      sumCost += @materials[i[0]][:Price] * i[1]
    end

    if productCost > sumCost
      # Request Materials
      haveMaterials = []
      recipe.each do |i|
        if @materials[i[0]][:Stored] <= i[1] # If we don't have enough materials
          haveMaterials << false
          @materials[i[0]][:Price] = (@materials[i[0]][:Price] + 0.01).round(2) # Increase the price with increased deman
        else
          haveMaterials << true
        end
      end

      unless haveMaterials.include? false # Don't craft if we're missing materials
        recipe.each do |i|
          @materials[i[0]][:Stored] = (@materials[i[0]][:Stored] - i[1]).round(2)
        end
        @materials[product[0]][:Stored] = (@materials[product[0]][:Stored] + product[1]).round(2)
        @materials[product[0]][:Price] -= 0.1
        @materials[product[0]][:Price] = @materials[product[0]][:Price].round(2)
      end

    else
      #
      # recipe.each { |i|
      #  @materials[i[0]][:Price] = (@materials[i[0]][:Price] - 0.01).round(2)
      # }
    end
  end

  def draw(_args)
    { x: @x, y: @y, w: 28, h: 28, path: @image, primitive_marker: :sprite }
  end
end
