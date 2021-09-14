# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1829
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Francis Tresham'
        GAME_INFO_URL = 'https://google.com'
        GAME_LOCATION = 'United Kingdom'
        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [2, 9].freeze
        OPTIONAL_RULES = [

          {
            sym: :k1,
            short_name: 'k1',
            desc: 'Extension Kit 1 -  gray and browngray Tiles',
          },
          {
            sym: :k3,
            short_name: 'k3',
            desc: 'Extension Kit 2 - Advanced Trains (3T, 2+2, 4+4E)',
          },
          {
            sym: :k5,
            short_name: 'k5',
            desc: 'Extension Kit 5 - extra Tiles (55,56,11,69)',
          },
          {
            sym: :k6,
            short_name: 'k6',
            desc: 'Extension Kit 6 - Advanced Tiles (52,64,65,66,67,68 (OO Tiles)',
          },
        ].freeze
      end
    end
  end
end
