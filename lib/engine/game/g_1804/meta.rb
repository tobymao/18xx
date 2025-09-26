# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1804
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_DESIGNER = 'Joe Clancy'
        GAME_LOCATION = 'American Political Landscape'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/304000/1804-truncated-rules-v1'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
