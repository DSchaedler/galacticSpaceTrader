# frozen_string_literal: true

# Instance class of the player ship.
class ObjectShip < Object
  attr_accessor :name, :money, :fuel, :cores, :materials

  def initialize
    # @name = 'Ship'
    @money = 1000
    # @fuel = 1000

    @materials = {}
    RESOURCES.each do |resource|
      resource_info = {}
      resource_info[:Stored] = 0
      resource_info[:Paid] = 0
      @materials[resource] = resource_info
    end
    #@materials['Water'] = { Stored: 0, Paid: 0 }
    @materials['Cores'] = { Stored: 10, Paid: 0 }
    @materials['Fuel'] = { Stored: 1000, Paid: 0 }
  end
end
