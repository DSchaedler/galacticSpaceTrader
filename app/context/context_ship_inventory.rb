# frozen_string_literal: true

# Handles calculations and drawing of the ship inventory screens.
class ContextShipInventory < Context
  def initialize(args)
    @element_padding = 10
    @sample_text = args.gtk.calcstringbox('Manganese')
    @column_width = @sample_text[0]
    @text_height = @sample_text[1]
    @column_count = 3
    @column_sort = :Stored

    @width = (@column_width * @column_count) + (@element_padding * (@column_count))
    @height = args.grid.h
    @origin_x = (args.grid.w / 2) - (@width / 2)
    @origin_y = args.grid.top

    @static_output = []

    @image_width = @column_width * 2
    @image_height = @image_width
  end

  def create_menu
    # Textbox
    @static_output << textbox_background(x_pos: @origin_x, y_pos: @origin_y,
                                         width: @width, height: @height - 32)


  end

  def destroy_menu
    @static_output = []
  end

  def tick(args)
    ship_frame = args.state.tick_count.idiv(5).mod(3)

    exit_button(args)

    $game.draw.layers[3] << @static_output

    if args.inputs.keyboard.key_up.escape
      destroy_menu
      $game.scene_main.context = :context_planet_map
    end

    # Start Table
    table = []

    # Define the start location of the table
    list_start = @origin_y - @image_height - (@text_height * 4)

    print_table(args, table, list_start)

    $game.draw.layers[3] << table # Make it so

    $game.draw.layers[3] << { x: @origin_x + (@width / 2) - (@image_width / 2) - @element_padding,
                        y: @origin_y - @image_height - @element_padding,
                        w: @image_width,
                        h: @image_height,
                        path: "sprites/spaceship#{ship_frame}.png",
                        primitive_marker: :sprite }
  end

  def exit_button(args)
    color = {a: 200, r: 168, g: 181, b: 178}
    box = {x: @origin_x + @width, y: @origin_y - 32, w: 32, h: 32}
    button_sprite = { path: 'sprites/rounded_x_box.png' }.merge(color)
    button_sprite = button_sprite.merge(box)

    $game.draw.layers[3] << button_sprite


    return unless args.inputs.mouse.click&.inside_rect?(box)
    destroy_menu
    $game.scene_main.context = :context_planet_map
  end

  def print_table(args, table, start_y)
    materials = $game.scene_main.ship.materials

    sorted_materials = materials.sort_by { |_material, values| -values[@column_sort] }

    # Draw the column headers for the table
    column_headers(args, table, start_y, sorted_materials[0][1])
    start_y -= @text_height

    row_index = 0
    sorted_materials.each do |row, value| # For each row of materials in the table
      print_columns(args, table, row_index, row, value, start_y) # Print all of the columns for that row.
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

      if args.inputs.mouse.intersect_rect? [label_hash[:x], label_hash[:y] - @text_height, @column_width, @text_height]
        @column_sort = key
      end
    end
  end

  def print_columns(args, table, row_index, row, contents, start_y)
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
  end
end