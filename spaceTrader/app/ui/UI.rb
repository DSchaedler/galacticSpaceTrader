class UI
end

class UIButton < UI
  def initialize (args, x, y, string, m)
    @string = string
    @material = m

    @string = string
    @stringBox = args.gtk.calcstringbox(@string)
    @stringSize = args.gtk.calcstringbox(@string, -1)
    @stringPadding = @stringBox[0] - @stringSize[0]
    
    @x = x
    @y = y + @stringBox[1]
    @w = @stringBox[0]
    @h = @stringBox[1]
    
    @buttonBox = [@x, @y + @h, @stringBox[0], @stringBox[1]]
    
    

    @staticOutput = []
  end

  def createButton (args)
    @staticOutput << {x: @x, y: @y - @h , w: @w, h: @h, r: 0, g: 0, b: 0, primitive_marker: :border}
    
    @staticOutput << {x: @x + @stringPadding, y: @y - @stringPadding , text: @string, size_enum: -1, primitive_marker: :label}
  end
  
  def destroyButton args
    @staticOutput = []
  end

  def tick args
    args.outputs.primitives << @staticOutput
  end
end

class UIBuyButton < UIButton
  def tick (args)
    args.outputs.primitives << @staticOutput
    if args.inputs.mouse.click
      if args.inputs.mouse.click.inside_rect? [@x, @y, @stringBox[0], @stringBox[1]]
        puts @material
        $game.sceneMain.ship.materials[@material][:stored] += 1
      end
    end
  end
end

class UISellButton < UIButton
  def tick (args)
    args.outputs.primitives << @staticOutput
    if args.inputs.mouse.click
      if args.inputs.mouse.click.inside_rect? [@x, @y, @stringBox[0], @stringBox[1]]
        puts @material
        $game.sceneMain.ship.materials[@material][:stored] -= 1
      end
    end
  end
end