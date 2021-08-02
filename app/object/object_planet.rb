# frozen_string_literal: true

# Instance class for every planet
class ObjectPlanet < Object
  # Creates attribute accessors for instance variables.
  # Just pretend that you have to declare instance variables and it will be fine.
  attr_accessor :x
  attr_accessor :y, :type, :name, :image, :materials

  def initialize(args, planet_name)
    # Generate unique planet information
    @x = randr(64, args.grid.right - 64)
    @y = randr(64, args.grid.top - 64)
    @type = PLANET_TYPE_STRINGS.sample
    @name = planet_name

    # Randomly determine which planet image we should use.
    # These two have fewer images available, so we treat them specially.
    @image = if @type == 'Inferno' || @type == 'Toxic'
               "sprites/PixelPlanets/#{@type.downcase}#{randr(0, 3)}.png"
             else
               "sprites/PixelPlanets/#{@type.downcase}#{randr(0, 5)}.png"
             end

    @materials = {}
    RESOURCES.each do |resource|
      resource_info = {}
      resource_info[:Rate] = randr(1, 10)
      resource_info[:Stored] = 0
      resource_info[:Price] = 100
      @materials[resource] = resource_info
    end

    # @materials['Water'] = { Rate: 0, Stored: 0, Price: 100 }
    @materials['Cores'] = { Rate: 0, Stored: randr(0, 1), Price: 300 }
    @materials['Fuel'] = { Rate: 0, Stored: 0, Price: 100 }
  end

  def cycle(args)
    total_stored = 0

    @materials.each do |_material, values|
      total_stored += values[:Stored]
    end

    if total_stored < 500
      @materials.each do |_material, values|
        if values[:Price].positive?
          values[:Stored] += values[:Rate]
          values[:Price] -= 1 if values[:Rate].positive?
        end
      end
      # factory(args, [['Water', 3], ['Hydrogen', 2], ['Oxygen', 1]])
      factory(args, [['Fuel', 5], ['Hydrogen', 1], ['Oxygen', 4]])
    end
  end

  def consume(_args, material, quantity)
    if @materials[material][:Stored] >= quantity
      @materials[material][:Stored] = (@materials[material][:Stored] - quantity)
    else
      @materials[material][:Price] = (@materials[material][:Price] + (1 * quantity))
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
      if @materials[i[0]][:Stored] < i[1] # If we don't have enough materials
        have_materials << false
        @materials[i[0]][:Price] = (@materials[i[0]][:Price] + 1) # Increase the price with increased deman
      else
        have_materials << true
      end
    end

    return if have_materials.include? false # Don't craft if we're missing materials

    recipe.each do |i|
      @materials[i[0]][:Stored] = (@materials[i[0]][:Stored] - i[1])
    end
    @materials[product[0]][:Stored] = (@materials[product[0]][:Stored] + product[1])
    @materials[product[0]][:Price] -= 1
    @materials[product[0]][:Price] = @materials[product[0]][:Price]
  end

  def draw
    { x: @x, y: @y, w: 28, h: 28, path: @image, primitive_marker: :sprite }
  end
end
