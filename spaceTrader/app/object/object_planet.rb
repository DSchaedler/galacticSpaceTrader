# frozen_string_literal: true

# Instance class for every planet
class ObjectPlanet < Object
  # Creates attribute accessors for instance variables.
  # Just pretend that you have to declare instance variables and it will be fine.
  attr_accessor :x
  attr_accessor :y, :type, :name, :image, :materials

  def initialize(planet_name)
    # Generate unique planet information
    @x = randr(1, 37) * 32
    @y = randr(3, 21) * 32
    @type = PLANET_TYPE_STRINGS.sample
    @name = planet_name

    # Randomly determine which planet image we should use.
    # These two have fewer images available, so we treat them specially.
    @image = if @type == 'Inferno' || @type == 'Toxic'
               "sprites/PixelPlanets/#{@type.downcase}#{randr(0, 3)}.png"
             else
               "sprites/PixelPlanets/#{@type.downcase}#{randr(0, 5)}.png"
             end

    i = 0
    @materials = {}
    RESOURCES.each do |resource|
      resource_info = {}
      resource_info[:Rate] = randr(0.01, 1).round(2)
      resource_info[:Stored] = 0
      resource_info[:Price] = 10
      @materials[resource] = resource_info
      i += 1
    end

    @materials['Water'] = { Rate: 0, Stored: 0, Price: 10 }
    @materials['Fuel'] = { Rate: 0, Stored: 0, Price: 10 }
  end

  def cycle(args)
    total_stored = 0

    @materials.each do |_material, values|
      total_stored += values[:Stored]
    end

    if total_stored < 1000
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

  def factory(_args, recipe)
    # recipe = [[product, int], [ingredient, int], [...]]
    product = recipe[0]
    recipe.shift

    product_cost = @materials[product[0]][:Price] * product[1]

    sum_cost = 0
    recipe.each do |i|
      sum_cost += @materials[i[0]][:Price] * i[1]
    end

    return unless product_cost > sum_cost

    # Request Materials
    have_materials = []
    recipe.each do |i|
      if @materials[i[0]][:Stored] <= i[1] # If we don't have enough materials
        have_materials << false
        @materials[i[0]][:Price] = (@materials[i[0]][:Price] + 0.01).round(2) # Increase the price with increased deman
      else
        have_materials << true
      end
    end

    return unless have_materials.include? false # Don't craft if we're missing materials

    recipe.each do |i|
      @materials[i[0]][:Stored] = (@materials[i[0]][:Stored] - i[1]).round(2)
    end
    @materials[product[0]][:Stored] = (@materials[product[0]][:Stored] + product[1]).round(2)
    @materials[product[0]][:Price] -= 0.1
    @materials[product[0]][:Price] = @materials[product[0]][:Price].round(2)
  end

  def draw
    { x: @x, y: @y, w: 28, h: 28, path: @image, primitive_marker: :sprite }
  end
end
