# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1822/meta'

module Engine
  module Game
    module G1822MX
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = 'The Railways of Mexico'
        GAME_DESIGNER = 'Scott Peterson'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822MX'
        GAME_LOCATION = 'Mexico'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = {
          'Rules' => 'https://boardgamegeek.com/filepage/206630/1822mx-rules',
          '2-player rules (BGG thread)' => 'https://boardgamegeek.com/thread/2594249/article/36912132#36912132',
        }.freeze

        GAME_TITLE = '1822MX'

        OPTIONAL_RULES = [
          {
            sym: :higher_cert_limit,
            short_name: 'Higher Certificate Counts (Prototype Variant)',
            desc: 'Increase certificate limit to 18/14/11 for 3/4/5 player games',
            players: [3, 4, 5],
          },
        ].freeze

        PLAYER_RANGE = [2, 5].freeze
      end
    end
  end
end
