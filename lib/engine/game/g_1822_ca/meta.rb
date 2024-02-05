# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1822/meta'

module Engine
  module Game
    module G1822CA
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = 'The Railways of Canada'
        GAME_DESIGNER = 'Robert Lecuyer & Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822CA'
        GAME_LOCATION = 'Canada'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = {
          'Rules' => 'https://boardgamegeek.com/filepage/238950/1822ca-rules',
          '2-player Scenarios' => 'https://boardgamegeek.com/thread/2591186/1822ca-2-player-scenarios',
        }.freeze
        GAME_TITLE = '1822CA'
        GAME_ISSUE_LABEL = '1822CA'

        PLAYER_RANGE = [2, 7].freeze

        GAME_VARIANTS = [
          {
            sym: :ers,
            name: 'Eastern Regional Scenario',
            title: '1822CA ERS',
            desc: 'shorter game on the eastern half of the map',
          },
          {
            sym: :wrs,
            name: 'Western Regional Scenario',
            title: '1822CA WRS',
            desc: 'shorter game on the western half of the map',
          },
        ].freeze
      end
    end
  end
end
