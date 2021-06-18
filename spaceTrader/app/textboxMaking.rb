# frozen_string_literal: true

def textboxBackground(_args, x:, y:, w:, h:, segment: 32)
  y -= segment

  textbox = []
  textbox << [x, y, segment, segment, 'sprites/textbox/textbox0.png'].sprite
  textbox << [x + segment, y, w - segment * 2, segment, 'sprites/textbox/textbox1.png'].sprite
  textbox << [x + w - segment, y, segment, segment, 'sprites/textbox/textbox2.png'].sprite
  textbox << [x, y - h + segment * 2, segment, h - segment * 2, 'sprites/textbox/textbox3.png'].sprite
  textbox << [x + segment, y - h + segment * 2, w - segment * 2, h - segment * 2, 'sprites/textbox/textbox4.png'].sprite
  textbox << [x + w - segment, y - h + segment * 2, segment, h - segment * 2, 'sprites/textbox/textbox5.png'].sprite
  textbox << [x, y - h + segment, segment, segment, 'sprites/textbox/textbox6.png'].sprite
  textbox << [x + segment, y - h + segment, w - segment * 2, segment, 'sprites/textbox/textbox7.png'].sprite
  textbox << [x + w - segment, y - h + segment, segment, segment, 'sprites/textbox/textbox8.png'].sprite

  textbox
end
