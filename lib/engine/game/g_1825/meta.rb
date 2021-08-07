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

        PLAYER_RANGE = [2, 9].freeze
        OPTIONAL_RULES = [
          {
            sym: :unit_1,
            short_name: 'Unit 1',
            desc: 'Unit 1 [default]',
          },
          {
            sym: :unit_2,
            short_name: 'Unit 2',
            desc: 'Unit 2',
          },
          {
            sym: :unit_3,
            short_name: 'Unit 3',
            desc: 'Unit 3',
          },
        ].freeze
      end
    end
  end
end
