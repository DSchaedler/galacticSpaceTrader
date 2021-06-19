# frozen_string_literal: true

# Handles calculations and drawing of the planet data screens.
class ContextPlanetMenu < Context
  def initialize(args)
    @element_padding = 10
    @sample_text = args.gtk.calcstringbox('Manganese')
    @column_width = @sample_text[0]
    @text_height = @sample_text[1]
    @image_width = @column_width * 2
    @image_height = @image_width
    @column_count = 8
    @column_sort = :Stored

    @width = (@column_width * @column_count) + (@element_padding * (@column_count + 1))
    @height = args.grid.h
    @originX = (args.grid.w / 2) - (@width / 2)
    @originY = args.grid.top

    @staticOutput = []
    @planet = nil
  end

  def create_menu(planet)
    # Textbox
    @staticOutput << textbox_background(x: @originX,
                                        y: @originY,
                                        w: @column_width * @column_count + @element_padding * 4,
                                        h: @height)
    # Planet Image
    @staticOutput << { x: @originX + (@width / 2) - (@image_width / 2) - @element_padding,
                       y: @originY - @image_height - @element_padding,
                       w: @image_width,
                       h: @image_height,
                       path: planet.image,
                       primitive_marker: :sprite }
    # Planet Name
    @staticOutput << { x: @originX + @element_padding,
                       y: @originY - @image_height - @element_padding - (@text_height * 1),
                       text: planet.name,
                       primitive_marker: :label }
    # Planet Type
    @staticOutput << { x: @originX + @element_padding,
                       y: @originY - @image_height - @element_padding - (@text_height * 2),
                       text: planet.type, primitive_marker: :label }

    @planet = planet
  end

  def destroyMenu
    @staticOutput = []
  end

  def tick(args)
    args.outputs.primitives << @staticOutput

    if args.inputs.keyboard.key_up.escape
      destroyMenu(args)
      $game.scene_main.context = :context_planet_map
    end

    # Start Table
    table = []
    buttons = []

    # Define the start location of the table
    listStart = @originY - @image_height - (@text_height * 4)

    printTable(args, table, buttons, @planet, listStart)

    buttons.each { |button|; button.tick(args, @planet); } # Tick buttons

    args.outputs.primitives << table # Make it so
  end

  def printTable(args, table, buttons, planet, startY)
    materials = planet.materials
    materials.each do |m, v| # Append how much the ship is storing to the table
      v[:Ship] = $game.scene_main.ship.materials[m][:Stored]
      if $game.scene_main.ship.materials[m][:Stored] <= 0
        $game.scene_main.ship.materials[m][:Paid] = 0
        shipPaid = 0
      else
        shipPaid = $game.scene_main.ship.materials[m][:Paid]
        # shipPaid = ($game.scene_main.ship.materials[m][:Paid] / $game.scene_main.ship.materials[m][:Stored]).round(2)
      end
      v[:ShipPaid] = $game.scene_main.ship.materials[m][:Paid] if shipPaid
    end

    sortedMaterials = materials.sort_by { |_material, values| -values[@column_sort] }

    # Draw the column headers for the table
    columnHeaders(args, table, startY, sortedMaterials[0][1])
    startY -= @text_height

    rowIndex = 0
    sortedMaterials.each do |row, value| # For each row of materials in the table
      printColumns(args, table, buttons, rowIndex, row, value, startY) # Print all of the columns for that row.
      rowIndex += 1
    end
  end

  def columnHeaders(args, table, startY, hash)
    columnIndex = 1
    hash.each do |key, _value|
      labelHash = { x: @originX + (@column_width * columnIndex) + (@element_padding * (columnIndex + 1)),
                    y: startY,
                    text: key,
                    primitive_marker: :label }
      table << labelHash
      columnIndex += 1

      # Allows rows to be sorted by column values
      # Click the column header to sort
      next unless args.inputs.mouse.click

      if args.inputs.mouse.intersect_rect? [labelHash[:x], labelHash[:y] - @text_height, @column_width, @text_height]
        @column_sort = key
      end
    end
  end

  def printColumns(args, table, buttons, rowIndex, row, contents, startY)
    columnIndex = 0

    # Put the element name at the beginning of the row
    table << { x: @originX + (@column_width * columnIndex) + (@element_padding * (columnIndex + 1)), y: startY - (@text_height * rowIndex), text: row, primitive_marker: :label }
    columnIndex += 1

    # Iterate through remaining columns and print
    contents.each do |_column, value|
      # OUTPUT CODE
      table << { x: @originX + (@column_width * columnIndex) + (@element_padding * (columnIndex + 1)), y: startY - (@text_height * rowIndex), text: value, primitive_marker: :label }
      columnIndex += 1
    end

    # And add buy and sell buttons at the end of each row
    newButton = UIBuyButton.new(args, @originX + (@column_width * columnIndex) + (@element_padding * (columnIndex + 1)), startY - (@text_height * rowIndex), 'Buy', row)
    newButton.createButton(args)
    buttons << newButton
    # columnIndex += 1

    newButton = UISellButton.new(args, @originX + (@column_width * columnIndex) + (@element_padding * (columnIndex + 1)) + newButton.w + @element_padding, startY - (@text_height * rowIndex), 'Sell', row)
    newButton.createButton(args)
    buttons << newButton
  end
end
