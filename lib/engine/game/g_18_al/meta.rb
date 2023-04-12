# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18AL
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Mark Derrick'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18AL'
        GAME_LOCATION = 'Alabama, USA'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/80315/18al-rules-v17'

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :double_yellow_first_or,
            short_name: 'Extra yellow',
            desc: 'Allow corporation to lay 2 yellows its first OR',
          },
          {
            sym: :LN_home_city_moved,
            short_name: 'Move L&N home',
            desc: 'Move L&N home city to Decatur - Nashville becomes off board hex',
          },
          {
            sym: :unlimited_4d,
            short_name: 'Unlimited 4D',
            desc: 'Unlimited number of 4D',
          },
          {
            sym: :hard_rust_t4,
            short_name: 'Hard rust',
            desc: '4 trains rust when 7 train is bought',
          },
        ].freeze
      end
    end
  end
end
