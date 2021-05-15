class ContextPlanetMenu < Context
  
  def initialize args
    @elementPadding = 10
    @sampleText = args.gtk.calcstringbox("Manganese")
    @columnWidth = @sampleText[0]
    @textHeight = @sampleText[1]
    @imageWidth = @columnWidth * 2
    @imageHeight = @imageWidth
    @columnCount = 7
    @columnSort = :Stored

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

  def tick (args, planet)

    args.outputs.primitives << @staticOutput

    if args.inputs.keyboard.key_up.escape
      destroyMenu(args)
      $game.sceneMain.context = :contextPlanetMap
    end

    # Start Table
    table = []
    buttons = []

    # Define the start location of the table
    listStart = @originY - @imageHeight - ( @textHeight * 4 )
    
    printTable(args, table, buttons, planet, listStart)

    for button in buttons; button.tick(args, planet); end # Tick buttons

    args.outputs.primitives << table # Make it so

  end

  def printTable(args, table, buttons, planet, startY)
    materials = planet.materials
    materials.each {|m, v| # Append how much the ship is storing to the table
      v[:Ship] = $game.sceneMain.ship.materials[m][:Stored]
    }

    sortedMaterials = materials.sort_by {|material, values| -values[@columnSort]}

    # Draw the column headers for the table
    columnHeaders(args, table, startY, sortedMaterials[0][1]) 
    startY -= @textHeight
    
    rowIndex = 0
    sortedMaterials.each {|row, value| # For each row of materials in the table
      printColumns(args, table, buttons, rowIndex, row, value, startY) # Print all of the columns for that row.
      rowIndex += 1
    }
  
  end

  def columnHeaders( args, table, startY, hash )
    columnIndex = 1
    hash.each {|key, value|
      labelHash = {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: startY, text: key, primitive_marker: :label}
      table << labelHash
      columnIndex += 1

      # Allows rows to be sorted by column values
      # Click the column header to sort
      if args.inputs.mouse.click
        if args.inputs.mouse.intersect_rect? [labelHash[:x], labelHash[:y] - @textHeight, @columnWidth, @textHeight]
          @columnSort = key
        end
      end
    }
  end

  def printColumns(args, table, buttons, rowIndex, row, value, startY)
    columnIndex = 0
    
    # Put the element name at the beginning of the row
    table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: startY - ( @textHeight * rowIndex ), text: row, primitive_marker: :label}
    columnIndex += 1
    
    # Iterate through remaining columns and print
    value.each {|column, value|
      # OUTPUT CODE
      table << {x: @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), y: startY - ( @textHeight * rowIndex), text: value, primitive_marker: :label}
      columnIndex += 1
    }

    # And add buy and sell buttons at the end of each row
    newButton = UIBuyButton.new(args, @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), startY - ( @textHeight * rowIndex), "Buy", row)
    newButton.createButton(args)
    buttons << newButton
    columnIndex += 1

    newButton = UISellButton.new(args, @originX + (@columnWidth * columnIndex) + (@elementPadding * (columnIndex + 1)), startY - ( @textHeight * rowIndex), "Sell", row)
    newButton.createButton(args)
    buttons << newButton
  end

  
end