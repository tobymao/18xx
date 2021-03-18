# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822MRS
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = 'The Railways of Great Britain'
        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/219065/1822-railways-great-britain-rules'
        GAME_TITLE = '1822MRS'

        PLAYER_RANGE = [3, 7].freeze

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
