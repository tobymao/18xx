# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1836Jr56
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        # 1856 for obvious reasons
        DEPENDS_ON = '1856'

        GAME_DESIGNER = 'David G. D. Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1836Jr-56'
        GAME_LOCATION = 'Netherlands'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/114573/1836jr-56-rules'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :diesel_variant,
            short_name: 'Diesel variant',
            desc: 'Replaces 8-trains with $1100 Diesels (and $300 trade in discount)',
          },
        ].freeze
      end
    end
  end
end
