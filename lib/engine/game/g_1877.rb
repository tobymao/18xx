# frozen_string_literal: true

require_relative '../config/game/g_1877'
require_relative 'g_1817'

module Engine
  module Game
    class G1877 < G1817
      register_colors(black: '#16190e',
                      blue: '#165633',
                      brightGreen: '#0a884b',
                      brown: '#984573',
                      gold: '#904098',
                      gray: '#984d2d',
                      green: '#bedb86',
                      lavender: '#e96f2c',
                      lightBlue: '#bedef3',
                      lightBrown: '#bec8cc',
                      lime: '#00afad',
                      navy: '#003d84',
                      natural: '#e31f21',
                      orange: '#f2a847',
                      pink: '#ee3e80',
                      red: '#ef4223',
                      turquoise: '#0095da',
                      violet: '#e48329',
                      white: '#fff36b',
                      yellow: '#ffdea8')

      load_from_json(Config::Game::G1877::JSON)

      GAME_DESIGNER = 'Scott Petersen'
      GAME_PUBLISHER = :all_aboard_games
      GAME_LOCATION = 'Venezuela'

      DEV_STAGE = :prealpha
    end
  end
end
