# frozen_string_literal: true

require_relative '../meta'
1
module Engine
  module Game
    module G18BA
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        PROTOTYPE = true

        GAME_DESIGNER = 'Andy & Sven'
        GAME_LOCATION = 'Bavaria, Germany'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/238953'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18BA'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
