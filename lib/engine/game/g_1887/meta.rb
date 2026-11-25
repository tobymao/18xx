# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1887
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = 'The Sound and the Ferry'
        GAME_DESIGNER = 'Christopher Rao & Rohith Rokkam'
        GAME_IMPLEMENTER = 'Anshul Tibrewal'
        GAME_LOCATION = 'Puget Sound, Washington, USA'
        GAME_TITLE = '1887'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
