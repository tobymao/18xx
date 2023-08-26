# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18NL
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Helmut Ohley'
        GAME_LOCATION = 'The Netherlands'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/47246/corrected-english-manual-v2'
        GAME_INFO_URL = ''

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
