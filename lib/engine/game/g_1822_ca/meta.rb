# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1822/meta'

module Engine
  module Game
    module G1822CA
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = 'The Railways of Canada'
        GAME_DESIGNER = 'Robert Lecuyer'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'
        GAME_LOCATION = 'Canada'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/219065/1822-railways-great-britain-rules'
        GAME_TITLE = '1822CA'

        PLAYER_RANGE = [3, 7].freeze
      end
    end
  end
end
