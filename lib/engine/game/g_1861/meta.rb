# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1861
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '1867'

        GAME_SUBTITLE = 'The Railways of the Russian Empire'
        GAME_DESIGNER = 'Ian D. Wilson'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1861'
        GAME_LOCATION = 'Russia'
        GAME_PUBLISHER = :grand_trunk_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/212807/18611867-rulebook'
        GAME_TITLE = '1861'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :column_market,
            short_name: 'Column Stock Market',
            desc: 'Play with the Column (1D) Stock Market from 1867 rather than the default Grid (2D) Stock Market',
          },
        ].freeze
      end
    end
  end
end
