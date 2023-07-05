# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18GA
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Mark Derrick'
        GAME_TITLE = '18GA'
        GAME_SUBTITLE = 'The Railroads Come to Georgia'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18GA'
        GAME_LOCATION = 'Georgia, USA'
        GAME_RULES_URL = 'http://www.18xx.net/18GA/18GAr.txt'

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :double_yellow_first_or,
            short_name: 'Extra yellow',
            desc: 'Allow corporation to lay 2 yellows its first OR',
          },
          {
            sym: :new_georgia_florida_home,
            short_name: 'New Georgia & Florida home',
            desc: 'The Georgia & Florida Railroad home is moved from Albany to Columbus',
          },
          {
            sym: :soft_rust_4t,
            short_name: 'Soft rust',
            desc: '4 trains run once more after 8 train is bought',
          },
        ].freeze
      end
    end
  end
end
