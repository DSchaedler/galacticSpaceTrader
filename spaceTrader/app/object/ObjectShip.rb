class ObjectShip < Object
  attr_accessor :name
  attr_accessor :money
  attr_accessor :materials

  def initialize args
    @name = "Ship"
    @money = 1000.00
    
    i = 0
    @materials = {}
    for resource in RESOURCES
      resourceInfo = {}
      resourceInfo[:Stored] = 0
      @materials[resource] = resourceInfo
      i += 1
    end
    puts @materials
    @materials["Water"] = {:Stored => 0}
    puts @materials
  end
end