# frozen_string_literal: true

class UI
end

class UIButton < UI
  attr_accessor :w

  def initialize(args, x, y, string, m)
    @string = string
    @material = m

    @stringBox = args.gtk.calcstringbox(@string)

    @x = x
    @y = y
    @w = @stringBox[0]
    @h = @stringBox[1]

    @buttonBox = [@x, @y + @h, @stringBox[0], @stringBox[1]]

    @stringSize = args.gtk.calcstringbox(@string, -1)
    @stringPadding = @stringBox[0] - @stringSize[0]

    @staticOutput = []
  end

  def createButton(_args)
    @staticOutput << { x: @x, y: @y - @h, w: @w, h: @h, r: 0, g: 0, b: 0, primitive_marker: :border }

    @staticOutput << { x: @x + @stringPadding, y: @y - @stringPadding, text: @string, size_enum: -1, primitive_marker: :label }
  end

  def destroyButton(_args)
    @staticOutput = []
  end

  def tick(args); end
end

class UIBuyButton < UIButton
  def tick(args, planet)
    args.outputs.primitives << @staticOutput
    if args.inputs.mouse.click&.inside_rect?(@staticOutput[0])
      if (planet.materials[@material][:Stored] >= 1) && ($game.sceneMain.ship.money >= planet.materials[@material][:Price])
        $game.sceneMain.ship.materials[@material][:Paid] += planet.materials[@material][:Price]
        $game.sceneMain.ship.materials[@material][:Paid] = $game.sceneMain.ship.materials[@material][:Paid].round(2)
        $game.sceneMain.ship.materials[@material][:Stored] += 1
        $game.sceneMain.ship.materials[@material][:Stored] = $game.sceneMain.ship.materials[@material][:Stored].round(2)
        $game.sceneMain.ship.money -= planet.materials[@material][:Price]
        $game.sceneMain.ship.money = $game.sceneMain.ship.money.round(2)
        planet.materials[@material][:Stored] -= 1
        planet.materials[@material][:Price] += 0.05
        planet.materials[@material][:Price] = planet.materials[@material][:Price].round(2)
      end
    end
  end
end

class UISellButton < UIButton
  def tick(args, planet)
    args.outputs.primitives << @staticOutput
    return unless args.inputs.mouse.click&.inside_rect? @staticOutput[0]

    return unless $game.sceneMain.ship.materials[@material][:Stored] >= 1

    $game.sceneMain.ship.materials[@material][:Stored] -= 1
    $game.sceneMain.ship.materials[@material][:Paid] -= ($game.sceneMain.ship.materials[@material][:Paid] / $game.sceneMain.ship.materials[@material][:Stored]).round(2)
    $game.sceneMain.ship.materials[@material][:Paid] = $game.sceneMain.ship.materials[@material][:Paid].round(2)
    $game.sceneMain.ship.materials[@material][:Stored] = $game.sceneMain.ship.materials[@material][:Stored].round(2)
    $game.sceneMain.ship.money += planet.materials[@material][:Price]
    $game.sceneMain.ship.money = $game.sceneMain.ship.money.round(2)
    planet.materials[@material][:Stored] += 1
    planet.materials[@material][:Price] -= 0.05
    planet.materials[@material][:Price] = planet.materials[@material][:Price].round(2)
  end
end
