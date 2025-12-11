# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18BB
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1846'

        GAME_TITLE = '18BB'
        GAME_DISPLAY_TITLE = '18BB'
        GAME_FULL_TITLE = '18 Barons of the Backwaters'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
