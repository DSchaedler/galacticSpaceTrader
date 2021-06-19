# frozen_string_literal: true

def textbox_background(x_pos:, y_pos:, width:, height:, segment: 32)
  y_pos -= segment
  textbox = []
  textbox << [x_pos, y_pos, segment, segment, 'sprites/textbox/textbox0.png'].sprite
  textbox << [x_pos + segment, y_pos, width - segment * 2, segment, 'sprites/textbox/textbox1.png'].sprite
  textbox << [x_pos + width - segment, y_pos, segment, segment, 'sprites/textbox/textbox2.png'].sprite
  textbox << [x_pos, y_pos - height + segment * 2, segment, height - segment * 2, 'sprites/textbox/textbox3.png'].sprite
  textbox << [x_pos + segment, y_pos - height + segment * 2, width - segment * 2, height - segment * 2,
              'sprites/textbox/textbox4.png'].sprite
  textbox << [x_pos + width - segment, y_pos - height + segment * 2, segment, height - segment * 2,
              'sprites/textbox/textbox5.png'].sprite
  textbox << [x_pos, y_pos - height + segment, segment, segment, 'sprites/textbox/textbox6.png'].sprite
  textbox << [x_pos + segment, y_pos - height + segment, width - segment * 2, segment,
              'sprites/textbox/textbox7.png'].sprite
  textbox << [x_pos + width - segment, y_pos - height + segment, segment, segment,
              'sprites/textbox/textbox8.png'].sprite
  textbox
end
