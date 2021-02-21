# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1877
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        DEPENDS_ON = '1817'

        GAME_DESIGNER = 'Scott Petersen & Toby Mao'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1877'
        GAME_LOCATION = 'Venezuela'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1877'

        PLAYER_RANGE = [2, 7].freeze
        OPTIONAL_RULES = [
          {
            sym: :cross_train,
            short_name: 'Cross Train Purchases',
            desc: 'Allows corporations to purchase trains from others',
          },
        ].freeze
      end
    end
  end
end
