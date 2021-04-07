# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18CZ
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_SUBTITLE = 'The Railway Comes to Czech Lands'
        GAME_DESIGNER = 'Leonhard Orgler'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18CZ'
        GAME_LOCATION = 'Czech Republic'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://www.lonny.at/app/download/9940504884/rules_English.pdf'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
