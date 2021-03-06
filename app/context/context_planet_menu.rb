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
    @column_count = 7
    @column_sort = :Stored

    @width = (@column_width * @column_count) + (@element_padding * (@column_count + 1))
    @height = args.grid.h
    @origin_x = (args.grid.w / 2) - (@width / 2)
    @origin_y = args.grid.top

    @static_output = []
    @planet = nil
  end

  def create_menu(args, planet)
    args.render_target(:planet_menu).clear_before_render = true
    # Textbox
    @static_output << textbox_background(x_pos: @origin_x,
                                         y_pos: @origin_y,
                                         width: @width,
                                         height: @height - 32)
                                         
    # Planet Name
    @static_output << { x: @origin_x + @element_padding,
                        y: @origin_y - @image_height - @element_padding - (@text_height * 1),
                        text: planet.name,
                        primitive_marker: :label }
    # Planet Type
    @static_output << { x: @origin_x + @element_padding,
                        y: @origin_y - @image_height - @element_padding - (@text_height * 2),
                        text: planet.type, primitive_marker: :label }

    args.render_target(:planet_menu).primitives << @static_output

    @planet = planet
    @table = []
  end

  def destroy_menu(args)
    @static_output = []
    args.render_target(:planet_menu).clear_before_render = true
  end

  def tick(args)
    exit_button(args)

    $game.draw.layers[3] << { x: 0, y: 0, w: 1280, h: 720, path: :planet_menu, primitive_marker: :sprite }
    $game.draw.layers[3] << @planet.draw.merge({ x: @origin_x + (@width / 2) - (@image_width / 2) - @element_padding,
      y: @origin_y - @image_height - @element_padding,
      w: @image_width,
      h: @image_height})

    if args.inputs.keyboard.key_up.escape
      destroy_menu(args)
      $game.scene_main.context = :context_planet_map
    end

    # Start Table
    table = []
    buttons = []

    # Define the start location of the table
    list_start = @origin_y - @image_height - (@text_height * 4)

    print_table(args, table, buttons, @planet, list_start)

    buttons.each { |button|; button.tick(args, @planet); } # Tick buttons

    if table != @table
      # args.render_target(:table_values).clear_before_render = true
      # args.render_target(:table_values).primitives << table
      @table = table
    end

    $game.draw.layers[3] << @table
  end

  def exit_button(args)
    color = { a: 200, r: 168, g: 181, b: 178 }
    box = { x: @origin_x + @width, y: @origin_y - 32, w: 32, h: 32 }
    button_sprite = { path: 'sprites/rounded_x_box.png' }.merge(color)
    button_sprite = button_sprite.merge(box)

    $game.draw.layers[3] << button_sprite

    return unless args.inputs.mouse.click&.inside_rect?(box)

    destroy_menu(args)
    $game.scene_main.context = :context_planet_map
  end

  def print_table(args, table, buttons, planet, start_y)
    materials = planet.materials
    materials.each do |m, v| # Append how much the ship is storing to the table
      v[:Ship] = $game.scene_main.ship.materials[m][:Stored]
      if $game.scene_main.ship.materials[m][:Stored] <= 0
        $game.scene_main.ship.materials[m][:Paid] = 0
        ship_paid = 0
      else
        ship_paid = ($game.scene_main.ship.materials[m][:Paid] / $game.scene_main.ship.materials[m][:Stored]).round(2)
      end
      v[:ShipPaid] = ship_paid if ship_paid
    end

    sorted_materials = materials.sort_by { |_material, values| -values[@column_sort] }

    # Draw the column headers for the table
    column_headers(args, table, start_y, sorted_materials[0][1])
    start_y -= @text_height

    row_index = 0
    sorted_materials.each do |row, value| # For each row of materials in the table
      print_columns(args, table, buttons, row_index, row, value, start_y) # Print all of the columns for that row.
      row_index += 1
    end
  end

  def column_headers(args, table, start_y, hash)
    column_index = 1
    hash.each_key do |key|
      label_hash = { x: @origin_x + (@column_width * column_index) + (@element_padding * (column_index + 1)),
                     y: start_y,
                     text: key,
                     primitive_marker: :label }
      table << label_hash
      column_index += 1

      # Allows rows to be sorted by column values
      # Click the column header to sort
      next unless args.inputs.mouse.click

      @column_sort = key if args.inputs.mouse.intersect_rect? [label_hash[:x], label_hash[:y] - @text_height, @column_width, @text_height]
    end
  end

  def print_columns(args, table, buttons, row_index, row, contents, start_y)
    column_index = 0

    # Put the element name at the beginning of the row
    table << { x: @origin_x + (@column_width * column_index) + (@element_padding * (column_index + 1)),
               y: start_y - (@text_height * row_index), text: row, primitive_marker: :label }
    column_index += 1

    # Iterate through remaining columns and print
    contents.each_value do |value|
      # OUTPUT CODE
      table << { x: @origin_x + (@column_width * column_index) + (@element_padding * (column_index + 1)),
                 y: start_y - (@text_height * row_index), text: value, primitive_marker: :label }
      column_index += 1
    end

    # And add buy and sell buttons at the end of each row
    new_button = UIBuyButton.new(
      args, @origin_x + (@column_width * column_index) +
      (@element_padding * (column_index + 1)),
      start_y - (@text_height * row_index), 'Buy', row
    )

    new_button.create_button
    buttons << new_button
    # column_index += 1

    new_button = UISellButton.new(
      args, @origin_x + (@column_width * column_index) +
      (@element_padding * (column_index + 1)) +
      new_button.w + @element_padding,
      start_y - (@text_height * row_index), 'Sell', row
    )
    new_button.create_button
    buttons << new_button
  end
end
