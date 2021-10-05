# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1872
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true

        GAME_SUBTITLE = 'Nippon'
        GAME_DESIGNER = 'Douglas Triggs'
        GAME_IMPLEMENTER = 'Douglas Triggs'
        GAME_LOCATION = 'Honshū, Japan'
        # GAME_PUBLISHER = ''
        # GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/'
        # GAME_RULES_URL = ''

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
