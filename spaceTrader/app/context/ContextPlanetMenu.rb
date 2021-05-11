class ContextPlanetMenu < Context
  
  def initialize args
    @elementPadding = 10
    @sampleText = args.gtk.calcstringbox("Manganese")
    @columnWidth = @sampleText[0]
    @textHeight = @sampleText[1]
    @imageWidth = @columnWidth * 2
    @imageHeight = @imageWidth

    @originX = (args.grid.w / 2) - (((@columnWidth * 4) + (@elementPadding * 5)) / 2)
    @originY = args.grid.top
    @width = args.grid.w
    @height = args.grid.h

    @staticOutput = []
  end

  def createMenu(args, planet)
    # Textbox
    @staticOutput << textboxBackground(args, x: @originX, y: @originY, w: @columnWidth * 4 + @elementPadding * 5, h: @height)
    # Planet Image
    @staticOutput << { x: @originX + (@elementPadding * 2) + @imageWidth / 2, y: @originY - @imageHeight - @elementPadding, w: @imageWidth, h: @imageHeight, path: planet.image, primitive_marker: :sprite}
    # Planet Name
    @staticOutput << { x: @originX + @elementPadding, y: @originY - @imageHeight - @elementPadding - ( @textHeight * 1 ), text: planet.name, primitive_marker: :label}
    # Planet Type
    @staticOutput << { x: @originX + @elementPadding, y: @originY - @imageHeight - @elementPadding - ( @textHeight * 2 ), text: planet.type, primitive_marker: :label}
  end

  def destroyMenu(args)
    @staticOutput = []
  end

  def tick (args, planet) # Look, I know this section is messy, but it's way better than it used to be. I think.
    materials = planet.materials

    args.outputs.primitives << @staticOutput

    if args.inputs.keyboard.key_up.escape
      destroyMenu(args)
      $game.sceneMain.context = :contextPlanetMap
    end

    # Start Table
    table = []
    printIndex = 0

    # Hardcode the start height
    listStart = @originY - @imageHeight - ( @textHeight * 4 )

    # Column Labels
    table << {x: @originX + @elementPadding , y: listStart - ( @textHeight * printIndex ), text: "Element", primitive_marker: :label} #RESOURCE NAME
    table << {x: @originX + @columnWidth + @elementPadding * 2, y: listStart - ( @textHeight * printIndex), text: "Stored", primitive_marker: :label} #RESOURCE STORED
    table << {x: @originX + @columnWidth + @elementPadding * 3 + @columnWidth, y: listStart - ( @textHeight * printIndex), text: "Price", primitive_marker: :label} #RESOURCE STORED
    table << {x: @originX + @columnWidth + @elementPadding * 4 + @columnWidth + @columnWidth, y: listStart - ( @textHeight * printIndex), text: "Ship", primitive_marker: :label} #RESOURCE STORED
    
    # Increase the list start location to move a row down
    listStart = @originY - @imageHeight - ( @textHeight * 5 )

    materials.each {|m, v| # Append how much the ship is storing to the table
      v[:shipStored] = $game.sceneMain.ship.materials[m][:stored]
    }

    printindex = 0 # Tracks the row currently being printed
    sortedMaterials = materials.sort_by {|material, values| -values[:price]} # Sort materials by price
    sortedMaterials.each {|m, values| # For Each Row, print the following columns
      table << {x: @originX + @elementPadding , y: listStart - ( @textHeight * printIndex ), text: "#{m}", primitive_marker: :label} #RESOURCE NAME
      table << {x: @originX + @columnWidth + @elementPadding * 2, y: listStart - ( @textHeight * printIndex), text: values[:stored], primitive_marker: :label} #RESOURCE STORED
      table << {x: @originX + @columnWidth + @elementPadding * 3 + @columnWidth, y: listStart - ( @textHeight * printIndex), text: values[:price], primitive_marker: :label} #RESOURCE PRICE
      table << {x: @originX + @columnWidth + @elementPadding * 4 + @columnWidth + @columnWidth, y: listStart - ( @textHeight * printIndex), text: values[:shipStored], primitive_marker: :label} #RESOURCE STORED SHIP
      printIndex += 1
    }

    args.outputs.primitives << table # Make it so
  end
end