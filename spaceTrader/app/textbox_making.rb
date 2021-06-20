# frozen_string_literal: true

def textbox_background(x_pos:, y_pos:, width:, height:, segment: 32)
  y_pos -= segment
  alpha = 255
  r = 168
  g = 181
  b = 178
  textbox = []
  textbox << [x_pos, y_pos, segment, segment, 'sprites/textbox/textbox0.png', 0, alpha, r, g, b].sprite
  textbox << [x_pos + segment, y_pos, width - segment * 2, segment, 'sprites/textbox/textbox1.png', 0, alpha, r, g,
              b].sprite
  textbox << [x_pos + width - segment, y_pos, segment, segment, 'sprites/textbox/textbox2.png', 0, alpha, r, g,
              b].sprite
  textbox << [x_pos, y_pos - height + segment * 2, segment, height - segment * 2, 'sprites/textbox/textbox3.png', 0,
              alpha, r, g, b].sprite
  textbox << [x_pos + segment, y_pos - height + segment * 2, width - segment * 2, height - segment * 2,
              'sprites/textbox/textbox4.png', 0, alpha, r, g, b].sprite
  textbox << [x_pos + width - segment, y_pos - height + segment * 2, segment, height - segment * 2,
              'sprites/textbox/textbox5.png', 0, alpha, r, g, b].sprite
  textbox << [x_pos, y_pos - height + segment, segment, segment, 'sprites/textbox/textbox6.png', 0, alpha, r, g,
              b].sprite
  textbox << [x_pos + segment, y_pos - height + segment, width - segment * 2, segment,
              'sprites/textbox/textbox7.png', 0, alpha, r, g, b].sprite
  textbox << [x_pos + width - segment, y_pos - height + segment, segment, segment,
              'sprites/textbox/textbox8.png', 0, alpha, r, g, b].sprite
  textbox
end
