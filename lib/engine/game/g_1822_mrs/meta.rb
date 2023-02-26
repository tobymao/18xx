# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1822/meta'

module Engine
  module Game
    module G1822MRS
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = 'Medium Regional Scenario'
        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/219065/1822-railways-great-britain-rules'
        GAME_TITLE = '1822MRS'
        GAME_ISSUE_LABEL = '1822'
        GAME_IS_VARIANT_OF = G1822::Meta

        PLAYER_RANGE = [2, 7].freeze

        OPTIONAL_RULES = [
          {
            sym: :advanced,
            short_name: 'Advanced',
            desc: 'Play with P1-12 and M14 will start in minor bid box 1.',
          },
        ].freeze
      end
    end
  end
end
