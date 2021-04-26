=begin
Dee's Interface Library (di_lib)
Scripted User Interface elements fro DragonRuby Game Toolkit
========
The MIT License (MIT)
Copyright © 2020 D Schaedler
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
========
IMPORTANT INFORMATION
di_init must be run before the library can be used
=end

DI_COLORS = {
  black: [0, 0, 0],
  white: [255, 255, 255],
  red: [255, 0, 0],
  lime: [0, 255, 0],
  blue: [0, 0, 255],
  yellow: [255, 255, 0],
  cyan: [0, 255, 255],
  magenta: [255, 0, 255],
  silver: [192, 192, 192],
  gray: [128, 128, 128],
  maroon: [128, 0, 0],
  olive: [128, 128, 0],
  green: [0, 128, 0],
  purple: [128, 0, 128],
  teal: [0, 128, 128],
  navy: [0, 0, 128]
}

DI_TEXT_ALIGN = {
  left: 0,
  center: 1,
  right: 2
}

def di_lib(args, reset: false)
  args.state.di_init_done ||= false

  if reset == true
    args.state.di_init_done = false
  end

  if args.state.di_init_done == false
    args.state.di_button_box = Hash.new
    args.state.di_button_label = Hash.new

    args.state.di_checkboxes = Hash.new

    args.state.di_textstreans = Hash.new

    args.state.di_debug = false

    args.state.di_init_done = true
  end

end

def di_button(args, button_symbol:, string:, posx:, posy:, padding: 10, border_color: :black, text_color: :black, text_size: 0, text_allignment: 0, text_alpha: 255, font_file: "font.tff") #specify and render a new button
  #button_symbol - symbol, must be unique

  string_box = args.gtk.calcstringbox(string, text_size + 1) #Adding one here is a hack to get the size right

  args.state.di_button_box[button_symbol] = [posx, posy, string_box[0] + (padding *2), string_box[1] + (padding * 2)] + DI_COLORS[border_color]
  args.state.di_button_label[button_symbol] = [posx + padding, posy + string_box[1] + padding, string, text_size, text_allignment] + DI_COLORS[text_color] + [text_alpha, font_file]

  args.outputs.borders << args.state.di_button_box[button_symbol]
  args.outputs.labels << args.state.di_button_label[button_symbol]
end

def di_button_box_calculate(args, string:, posx:, posy:, padding: 10, text_size: 0, font_file: "font.tff")
  string_box = args.gtk.calcstringbox(string, text_size, font_file)

  return [posx, posy, string_box[0] + (padding * 2), string_box[1] + (padding * 2)]
end

def di_button_clicked(args, click_location:, button_symbol:) #returns true if click location intersects specified button_box
  #click_location - array, [x,y]
  if (click_location) && (click_location.intersect_rect? args.state.di_button_box[button_symbol])
    return true
  else
    return false
  end
end

def di_checkbox(args, checkbox_symobl:, posx:, posy:, width: 20, height: 20, border_color: :black, fill_color: :black, border_alpha: 255, fill_alpha: 255, state: false)
  border_color = DI_COLORS[border_color]
  fill_color = DI_COLORS[fill_color]

  args.state.di_checkboxes[checkbox_symobl] ||= {
    x:  posx,
    y:  posy,
    w:  width,
    h:  height,
    r:  border_color[0],
    g:  border_color[1],
    b:  border_color[2],
    a:  border_alpha,
    fill_r: fill_color[0],
    fill_g: fill_color[1],
    fill_b: fill_color[2],
    fill_a: fill_alpha,
    state: state
  }

  checkbox = args.state.di_checkboxes[checkbox_symobl]
  if checkbox[:state]
    args.outputs.solids << [posx, posy, width, height]
  end
  args.outputs.primitives << args.state.di_checkboxes[checkbox_symobl].border

  if args.inputs.mouse.click
    click_location = [args.inputs.mouse.click.point.x, args.inputs.mouse.click.point.y]

    if (click_location) && (click_location.intersect_rect? args.state.di_checkboxes[checkbox_symobl])
      checkbox[:state] = !checkbox[:state]
      args.state.di_checkboxes[checkbox_symobl] = checkbox
    end
  end
end

def di_checkbox_get(args, checkbox_symobl)
    checkbox = args.state.di_checkboxes[checkbox_symobl]
    return checkbox[:state]
end

def di_render_textstream(args, textstream_symbol:, posx:, posy:, width:, height:, order:, border_color: :black, font_color: :black, border_alpha: 255, text_alpha: 255, line_spacing: 10, font_file: "font.tff")

  border_color = DI_COLORS[border_color]
  font_color = DI_COLORS[font_color]

  args.outputs.borders << [posx, posy, width, height, border_color[0], border_color[1], border_color[2], border_alpha]

  args.state.di_textstreans[textstream_symbol].each { |string|
    textsize = args.gtk.calcstringbox(string)
    if order == "down"
      args.outputs.labels << [posx + line_spacing, posy + height - line_spacing, string]
      posy = posy - textsize[1] - line_spacing
    elsif order == "up"
      args.outputs.labels << [posx + line_spacing, posy + textsize[1] + line_spacing, string]
      posy = posy + textsize[1] - line_spacing
    else
      puts "[di_lib][Error:] Incorrect paramater passed for textstream order, assuming down."
      args.outputs.labels << [posx + line_spacing, posy + height - line_spacing, string]
      posy = posy - textsize[1] - line_spacing
    end
  }
end

def di_textbox(args, box_symbol:, text_array:, posx:, posy:, width:, text_size: 0, line_spacing: 10, alignment: :left, border_padding: 10, border_color: :black, text_color: :black, background_color: :white, border_alpha: 255, text_alpha: 255, background_alpha: 255, font_file: "font.tff")
  border_color = DI_COLORS[border_color]
  background_color = DI_COLORS[background_color]
  text_color = DI_COLORS[text_color]

  textsize = args.gtk.calcstringbox(text_array[0])
  height = ( textsize[1] * 3 ) + ( border_padding * 2 ) + ( line_spacing * 2 )

  args.outputs.primitives << [posx, posy, width, height, background_color[0], background_color[1], background_color[2], background_alpha].solid
  args.outputs.borders << [posx, posy, width, height, border_color[0], border_color[1], border_color[2], border_alpha]

  case alignment
    when :left
      alignment = 0
      posx = posx + border_padding
    when :center
      alignment = 1
      posx = posx + width / 2
    when :right
      alignment = 2
      posx = posx + width - border_padding
    else
      puts "[di_lib][Error:] Incorrect paramater passed for textbox alignment, assuming left."
      alignment = 0
  end

  text_array.each_with_index { |string, index|
    args.outputs.labels << [
      posx,
      posy + height - line_spacing,
      string,
      text_size,
      alignment,
      text_color[0],
      text_color[1],
      text_color[2],
      text_alpha,
      font_file
    ]
    posy = posy - textsize[1] - line_spacing
  }

end

def di_bordered_bar(args, bar_symbol:, posx:, posy:, width:, height:, percent:, alignment: :left, border_color: :black, bar_color: :black, border_padding: 5, border_alpha: 255, bar_alpha: 255)
  border_color = DI_COLORS[border_color]
  bar_color = DI_COLORS[bar_color]

  args.outputs.borders << [posx, posy, width, height, border_color[0], border_color[1], border_color[2], border_alpha]

  case alignment
    when :left
      args.outputs.primitives << [posx + border_padding, posy + border_padding, ( width - (border_padding * 2) ) * (percent/100), height - (border_padding * 2), bar_color[0], bar_color[1], bar_color[2], bar_alpha].solid
    when :center
      bar_width = ( width - ( border_padding * 2 ) ) * ( percent / 100 )
      posx = posx + ( width / 2 ) - ( bar_width / 2 )
      args.outputs.primitives << [posx, posy + border_padding, bar_width, height - (border_padding * 2), bar_color[0], bar_color[1], bar_color[2], bar_alpha].solid
    when :right
      bar_width = ( width - ( border_padding * 2 ) ) * ( percent / 100 )
      posx = posx + width - bar_width - (border_padding * 2)
      args.outputs.primitives << [posx + border_padding, posy + border_padding, bar_width, height - (border_padding * 2), bar_color[0], bar_color[1], bar_color[2], bar_alpha].solid
    else
      puts "[di_lib][Error:] Invalid paramater passed for bar alignment, assuming left"
      args.outputs.primitives << [posx + border_padding, posy + border_padding, ( width - (border_padding * 2) ) * (percent/100), height - (border_padding * 2), bar_color[0], bar_color[1], bar_color[1], bar_alpha].solid
    end
end

def reset #Allows the state to be reset at any time by calling this function, also mineutely shortens the call in the console
  $gtk.reset()
end
