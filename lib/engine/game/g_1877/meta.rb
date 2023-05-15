# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1877
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true
        DEPENDS_ON = '1817'

        GAME_TITLE = '1877: Venezuela'
        GAME_ISSUE_LABEL = '1877'
        GAME_DESIGNER = 'Scott Petersen & Toby Mao'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1877'
        GAME_LOCATION = 'Venezuela'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://docs.google.com/document/d/1HlnW2jPCMcxYisDX_CjNLMkwBz3nmwOQItsNKm13HRc'

        PLAYER_RANGE = [2, 7].freeze
        OPTIONAL_RULES = [
          {
            sym: :cross_train,
            short_name: 'Cross Train Purchases',
            desc: 'Allows corporations to purchase trains from others',
          },
          {
            sym: :no_mines,
            short_name: 'No Mine Tiles',
            desc: 'Do not use the mine tiles',
          },
        ].freeze
      end
    end
  end
end
