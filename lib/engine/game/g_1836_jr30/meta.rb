# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1836Jr30
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'David G. D. Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1836Jr-30'
        GAME_LOCATION = 'Netherlands'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/114572/1836jr-30-rules'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :multiple_brown_from_ipo,
            short_name: 'Buy Multiple Brown Shares From IPO',
            desc: 'Multiple brown shares may be bought from IPO as well as from pool',
          },
        ].freeze
      end
    end
  end
end
