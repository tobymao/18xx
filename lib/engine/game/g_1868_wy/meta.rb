# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1868WY
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'John Harres'
        # GAME_INFO_URL = ''
        # GAME_PUBLISHER = ''
        # GAME_RULES_URL = ''
        GAME_TITLE = '1868 Wyoming'
        GAME_FULL_TITLE = '1868: Boom and Bust in the Coal Mines and Oil Fields of Wyoming'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
