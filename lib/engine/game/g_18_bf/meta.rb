# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18BF
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true
        DEPENDS_ON = '1867'

        GAME_SUBTITLE = 'The Big Four'
        GAME_DESIGNER = 'Ian D Wilson'
        GAME_LOCATION = 'Great Britain'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
