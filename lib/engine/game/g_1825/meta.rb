# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1825
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Francis Tresham'
        GAME_INFO_URL = 'https://google.com'
        GAME_LOCATION = 'United Kingdom'
        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [2, 8].freeze
        OPTIONAL_RULES = [
          {
            sym: :unit_1,
            short_name: 'Unit 1',
            desc: '2-5 players',
          },
          {
            sym: :unit_2,
            short_name: 'Unit 2',
            desc: '2-3 players',
          },
          {
            sym: :unit_3,
            short_name: 'Unit 3',
            desc: '2 players',
          },
          {
            sym: :unit_12,
            short_name: 'Units 1+2',
            desc: '3-7 players',
          },
          {
            sym: :unit_23,
            short_name: 'Units 2+3',
            desc: '3-5 players',
          },
          {
            sym: :unit_123,
            short_name: 'Units 1+2+3',
            desc: '4-8 players',
          },
        ].freeze
      end
    end
  end
end
