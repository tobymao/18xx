# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Tokaido
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_TITLE = '18 Tokaido'
        GAME_DESIGNER = 'Douglas Triggs'
        GAME_LOCATION = 'Central Japan'
        # GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/'
        # GAME_RULES_URL = ''

        PLAYER_RANGE = [2, 4].freeze
      end
    end
  end
end
