# frozen_string_literal: true

# Instance class of the systems in the galaxy
class ObjectSystem < GameObject
  attr_accessor :system_planets, :x, :y, :name, :star_map

  def initialize(args, x, y)
    @name = $available_planet_names.sample
    $available_planet_names.delete(@name)

    puts "Creating Planets in #{@name} system"
    planet_count = randr(3, 6)
    puts "Creating #{planet_count} planets"
    @system_planets = []
    until @system_planets.length == planet_count
      planet_name = $available_planet_names.sample

      new_planet = ObjectPlanet.new(args, planet_name)
      new_planet_pos = [new_planet.x, new_planet.y]

      puts "Testing Canidate #{new_planet.name} at #{new_planet_pos}"

      planet_checks = []

      @system_planets.each do |planet|
        old_planet_pos = [planet.x, planet.y]

        too_close = args.geometry.point_inside_circle? new_planet_pos, old_planet_pos, 128

        planet_checks << too_close
      end

      if planet_checks.include? true
        puts 'Rejected Planet... Too Close'
      else
        $available_planet_names.delete(planet_name)
        @system_planets << new_planet
        puts 'Planet Accepted'
      end
    end

    puts "Created #{@system_planets.length} planets successfully"

    @star_map = ContextPlanetMap.new(args, system_planets: @system_planets)

    @x = x
    @y = y
  end

  def draw(_args)
    [@x, @y]
  end
end
