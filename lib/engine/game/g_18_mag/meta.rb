# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Mag
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_SUBTITLE = 'Hungarian Railway History'
        GAME_DESIGNER = 'Leonhard "Lonny" Orgler'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Mag'
        GAME_LOCATION = 'Hungary'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://www.lonny.at/games/18magyarorsz%C3%A1g/'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
