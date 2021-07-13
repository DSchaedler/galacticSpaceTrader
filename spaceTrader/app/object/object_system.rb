# frozen_string_literal: true

# Instance class of the systems in the galaxy
class ObjectSystem < Object
  attr_accessor :system_planets, :x, :y, :name

  def initialize(args)
    @planet_count = randr(3, 6)
    @system_planets = []
    @planet_count.times do
      planet_name = $available_planet_names.sample
      $available_planet_names.delete(planet_name)
      @system_planets << ObjectPlanet.new(args, planet_name)
    end

    @x = randr(64, args.grid.right - 64)
    @y = randr(64, args.grid.top - 64)

    @name = $available_planet_names.sample
    $available_planet_names.delete(@name)
  end

  def draw(_args)
    [@x, @y]
  end
end
