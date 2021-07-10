# frozen_string_literal: true

# super class for UI Elements
class UI
end

# Buy button on Planet Menus
class UIButton < UI
  attr_accessor :w

  def initialize(args, x_pos, y_pos, string, mat)
    @string = string
    @material = mat

    @string_box = args.gtk.calcstringbox(@string)

    @x = x_pos
    @y = y_pos
    @w = @string_box[0]
    @h = @string_box[1]

    @button_box = [@x, @y + @h, @string_box[0], @string_box[1]]

    @string_size = args.gtk.calcstringbox(@string, -1)
    @string_padding = @string_box[0] - @string_size[0]

    @static_output = []
  end

  def create_button
    @static_output << { x: @x, y: @y - @h, w: @w, h: @h, r: 0, g: 0, b: 0, primitive_marker: :border }

    @static_output << { x: @x + @string_padding,
                        y: @y - @string_padding,
                        text: @string,
                        size_enum: -1,
                        primitive_marker: :label }
  end

  def destroy_button
    @static_output = []
  end

  def tick; end
end

# Buy button on Planet Menus
class UIBuyButton < UIButton
  def tick(args, planet)
    args.outputs.primitives << @static_output
    return unless args.inputs.mouse.click&.inside_rect?(@static_output[0])
    return unless planet.materials[@material][:Stored] >= 1
    return unless $game.scene_main.ship.money >= planet.materials[@material][:Price]

    $game.scene_main.ship.materials[@material][:Paid] += planet.materials[@material][:Price]
    $game.scene_main.ship.materials[@material][:Stored] += 1
    $game.scene_main.ship.money -= planet.materials[@material][:Price]
    planet.materials[@material][:Stored] -= 1
    planet.materials[@material][:Price] += 1
  end
end

# Sell button on Planet Menus
class UISellButton < UIButton
  def tick(args, planet)
    args.outputs.primitives << @static_output
    return unless args.inputs.mouse.click&.inside_rect? @static_output[0]
    return unless $game.scene_main.ship.materials[@material][:Stored] >= 1

    $game.scene_main.ship.materials[@material][:Stored] -= 1
    $game.scene_main.ship.materials[@material][:Paid] -= ($game.scene_main.ship.materials[@material][:Paid] / $game.scene_main.ship.materials[@material][:Stored])
    $game.scene_main.ship.money += planet.materials[@material][:Price]
    planet.materials[@material][:Stored] += 1
    planet.materials[@material][:Price] -= 1
  end
end
