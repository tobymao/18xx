# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18MO
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1846'

        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18MO'
        GAME_LOCATION = 'Missouri, USA'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/18MO'

        PLAYER_RANGE = [2, 5].freeze
      end
    end
  end
end
