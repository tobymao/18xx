# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18AZ
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1846'

        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18NewEnglandNorth'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/18NewEnglandNorth'

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
