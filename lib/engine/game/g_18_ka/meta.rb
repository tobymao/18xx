# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18KA
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1856'

        GAME_DESIGNER = 'Matthew Gilzinger'
        GAME_INFO_URL = ''
        GAME_LOCATION = 'Tharsis, Mars'
        GAME_RULES_URL = ''

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
