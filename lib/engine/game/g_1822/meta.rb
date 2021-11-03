# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'The Railways of Great Britain'
        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :all_aboard_games
        GAME_VARIANTS = [
          {
            sym: :nrs,
            name: 'North Regional Scenario',
            title: '1822NRS',
            desc: 'shorter game on the northern part of the map',
          },
          {
            sym: :mrs,
            name: 'Medium Regional Scenario',
            title: '1822MRS',
            desc: 'shorter game on the southern part of the map',
          },
        ].freeze
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/219065/1822-railways-great-britain-rules'

        PLAYER_RANGE = [3, 7].freeze

        OPTIONAL_RULES = [
          {
            sym: :plus_expansion,
            short_name: '1822+',
            desc: '6 more minors and 3 more privates. The privates are categorized into blue (bidbox 1), '\
                  'dark grey (bidbox 2) and gold (bidbox 3) stacks.',
          },
        ].freeze
      end
    end
  end
end
