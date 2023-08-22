# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1822/meta'

module Engine
  module Game
    module G1822Africa
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true
        DEPENDS_ON = '1822'

        GAME_DESIGNER = 'Scott Petersen'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'
        GAME_LOCATION = 'Africa'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = ''
        GAME_TITLE = '1822Africa'
        GAME_ISSUE_LABEL = '1822Africa'

        PLAYER_RANGE = [2, 4].freeze

        GAME_VARIANTS = [].freeze
      end
    end
  end
end
