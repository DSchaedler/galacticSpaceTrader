# frozen_string_literal: true

# Engine Methods

def keyboard
  $gtk.args.inputs.keyboard
end

def randr(min, max)
  rand(max - min + 1) + min
end

# You can customize the buttons that show up in the Console.
class GTK::Console::Menu
  # STEP 1: Override the custom_buttons function.
  def custom_buttons
    [
      (button id: :reset_game,
              # row for button
              row: 4,
              # column for button
              col: 10,
              # text
              text: 'Reset $game',
              # when clicked call the custom_button_clicked function
              method: :reset_game_clicked),
      (button id: :rubocop,
              # row for button
              row: 4,
              # column for button
              col: 9,
              # text
              text: 'rubocop -a',
              # when clicked call the custom_button_clicked function
              method: :rubocop_button_clicked),
      (button id: :clear_console,
              # row for button
              row: 4,
              # column for button
              col: 8,
              # text
              text: 'Clear Console',
              # when clicked call the custom_button_clicked function
              method: :clear_console_button_clicked)
    ]
  end

  # STEP 2: Define the function that should be called.
  def reset_game_clicked
    $game = nil
    $gtk.reset
  end

  def rubocop_button_clicked
    puts 'Starting rubocop...'
    $gtk.args.gtk.system 'rubocop -a'
  end

  def clear_console_button_clicked
    $gtk.console.clear
  end
end
