# frozen_string_literal: true

require_relative '../config/game/g_1830'
require_relative 'base'

module Engine
  module Game
    class G1830 < Base
      register_colors(red: '#d1232a',
                      orange: '#f58121',
                      black: '#110a0c',
                      blue: '#025aaa',
                      lightBlue: '#8dd7f6',
                      yellow: '#ffe600',
                      green: '#32763f',
                      brightGreen: 'rgb(110,192,55)')
      GAME_LOCATION = 'Northeastern, USA and Southeastern Canada'
      GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1830re.html_Rules_1830-RE_EN.pdf'
      GAME_PUBLISHER = :lookout
      GAME_DESIGNER = 'Francis Tresham'

      load_from_json(Config::Game::G1830::JSON)
    end
  end
end
