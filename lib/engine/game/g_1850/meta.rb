# frozen_string_literal: true

require_relative '../meta'
# require_relative '../g_1870/meta'

module Engine
  module Game
    module G1850
      module Meta
        include Game::Meta
        # include G1870::Meta

        DEV_STAGE = :prealpha
        # DEPENDS_ON = '1870'

        GAME_TITLE = '1850'
        GAME_SUBTITLE = 'The MidWest'
        GAME_DESIGNER = 'Bill Dixon'
        # GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1850'
        GAME_LOCATION = 'The Midwestern USA'
        # GAME_RULES_URL = 'http://www.hexagonia.com/rules/MFG_1850.pdf'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
