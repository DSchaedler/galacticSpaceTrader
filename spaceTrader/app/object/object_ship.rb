# frozen_string_literal: true

# Instance class of the player ship.
class ObjectShip < Object
  attr_accessor :name, :money, :fuel, :cores, :materials

  def initialize
    @name = 'Ship'
    @money = 1000.00
    @fuel = 100.00
    @cores = 10

    i = 0
    @materials = {}
    RESOURCES.each do |resource|
      resource_info = {}
      resource_info[:Stored] = 0
      resource_info[:Paid] = 0
      @materials[resource] = resource_info
      i += 1
    end
    @materials['Water'] = { Stored: 0, Paid: 0 }
    @materials['Fuel'] = { Stored: 100, Paid: 0 }
  end
end
