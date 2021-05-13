class ContextPlanetMenu < Context
  
  def initialize args
    @elementPadding = 10
    @sampleText = args.gtk.calcstringbox("Manganese")
    @columnWidth = @sampleText[0]
    @textHeight = @sampleText[1]
    @imageWidth = @columnWidth * 2
    @imageHeight = @imageWidth
    @columnCount = 6

    @width = (@columnWidth * @columnCount) + (@elementPadding * (@columnCount + 1))
    @height = args.grid.h
    @originX = (args.grid.w / 2) - (@width / 2)
    @originY = args.grid.top

    @staticOutput = []
  end

  def createMenu(args, planet)
    # Textbox
    @staticOutput << textboxBackground(args, x: @originX, y: @originY, w: @columnWidth * @columnCount + @elementPadding * 4, h: @height)
    # Planet Image
    @staticOutput << { x: @originX + (@width / 2) - (@imageWidth / 2) - @elementPadding, y: @originY - @imageHeight - @elementPadding, w: @imageWidth, h: @imageHeight, path: planet.image, primitive_marker: :sprite}
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
    buttons = []
    rowIndex = 0
    columnIndex = 0

    # Hardcode the start height
    listStart = @originY - @imageHeight - ( @textHeight * 4 )

    # Column Labels
    table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: listStart - ( @textHeight * rowIndex ), text: "Element", primitive_marker: :label} #RESOURCE NAME
    columnIndex += 1
    table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: listStart - ( @textHeight * rowIndex), text: "Stored", primitive_marker: :label} #RESOURCE STORED
    columnIndex += 1
    table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: listStart - ( @textHeight * rowIndex), text: "Price", primitive_marker: :label} #RESOURCE STORED
    columnIndex += 1
    table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: listStart - ( @textHeight * rowIndex), text: "Ship", primitive_marker: :label} #RESOURCE STORED
    
    # Increase the list start location to move a row down
    listStart = @originY - @imageHeight - ( @textHeight * 5 )

    materials.each {|m, v| # Append how much the ship is storing to the table
      v[:shipStored] = $game.sceneMain.ship.materials[m][:stored]
    }

    rowIndex = 0
    columnIndex = 0
    sortedMaterials = materials.sort_by {|material, values| -values[:price]} # Sort materials by price
    sortedMaterials.each {|m, values| # For Each Row, print the following columns
      table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: listStart - ( @textHeight * rowIndex ), text: "#{m}", primitive_marker: :label} #RESOURCE NAME
      columnIndex += 1
      table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: listStart - ( @textHeight * rowIndex), text: values[:stored], primitive_marker: :label} #RESOURCE STORED
      columnIndex += 1
      table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: listStart - ( @textHeight * rowIndex), text: values[:price], primitive_marker: :label} #RESOURCE PRICE
      columnIndex += 1
      table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: listStart - ( @textHeight * rowIndex), text: values[:shipStored], primitive_marker: :label} #RESOURCE STORED SHIP
      columnIndex += 1
      newButton = UIBuyButton.new(args, @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), listStart - ( @textHeight * rowIndex), "Buy", m)
      newButton.createButton(args)
      buttons << newButton
      columnIndex += 1
      newButton = UISellButton.new(args, @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), listStart - ( @textHeight * rowIndex), "Sell", m)
      newButton.createButton(args)
      buttons << newButton
      columnIndex = 0
      rowIndex += 1
    }

    for button in buttons
      button.tick(args, planet)
    end

    args.outputs.primitives << table # Make it so
  end
end