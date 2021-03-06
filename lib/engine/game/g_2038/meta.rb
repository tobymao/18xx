# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G2038
      module Meta
        include Game::Meta

        # DEV_STAGE = :alpha

        GAME_DESIGNER = 'James Hlavaty, Thomas Lehmann'
        GAME_LOCATION = 'Outer Space'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/135017/2038-english-rules-and-supplements'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
