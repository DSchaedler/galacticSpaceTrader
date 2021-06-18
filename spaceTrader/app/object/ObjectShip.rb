# frozen_string_literal: true

class ObjectShip < Object
  attr_accessor :name
  attr_accessor :money
  attr_accessor :fuel
  attr_accessor :cores
  attr_accessor :materials

  def initialize(_args)
    @name = 'Ship'
    @money = 1000.00
    @fuel = 100.00
    @cores = 10

    i = 0
    @materials = {}
    RESOURCES.each do |resource|
      resourceInfo = {}
      resourceInfo[:Stored] = 0
      resourceInfo[:Paid] = 0
      @materials[resource] = resourceInfo
      i += 1
    end
    @materials['Water'] = { Stored: 0, Paid: 0 }
    @materials['Fuel'] = { Stored: 100, Paid: 0 }
  end
end
