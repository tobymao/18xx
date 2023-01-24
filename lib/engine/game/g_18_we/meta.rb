# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18WE
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1862'

        GAME_DESIGNER = 'Karl Ernst'
        GAME_INFO_URL = 'https://boardgamegeek.com/boardgame/317048/18we-western-europe'
        GAME_LOCATION = 'Western Europe'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://boardgamegeek.com/thread/2870523/'
        GAME_TITLE = '18WE'

        PLAYER_RANGE = [2, 8].freeze
      end
    end
  end
end
