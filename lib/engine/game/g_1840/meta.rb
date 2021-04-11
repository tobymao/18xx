# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1840
      module Meta
        include Game::Meta

        GAME_SUBTITLE = 'Vienna Tramways'
        GAME_DESIGNER = 'Leonhard Orgler'
        GAME_LOCATION = 'Vienna - Austria'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1840'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://www.lonny.at/app/download/9980248884/Rules_ENG_final.pdf?t=1601308994'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
