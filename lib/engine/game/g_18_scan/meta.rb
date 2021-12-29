# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Scan
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'David G.D. Hecht'
        GAME_LOCATION = 'Scandinavian peninsula'
        GAME_PUBLISHER = :deep_thought_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/233108/18scan-rules-v10-dtd-30-sep-2005'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Scan'
        GAME_SUBTITLE = 'Railroading under the Northern Lights'

        PLAYER_RANGE = [2, 4].freeze

        OPTIONAL_RULES = [
          {
            sym: :two_player_share_limit,
            short_name: '70% Corporation Holding Limit',
            desc: 'When enabled, in a 2p game a player can hold up to 70% of a corporation\'s shares',
            players: [2],
          },
        ].freeze
      end
    end
  end
end
