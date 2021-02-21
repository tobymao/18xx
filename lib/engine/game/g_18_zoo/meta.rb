# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18ZOO
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Paolo Russo'
        GAME_TITLE = '18ZOO'

        PLAYER_RANGE = [2, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :map_b,
            short_name: 'Map B',
            desc: '5 families',
            players: [2, 3, 4],
          },
          {
            sym: :map_c,
            short_name: 'Map C',
            desc: '5 families',
            players: [2, 3, 4],
          },
          {
            sym: :map_d,
            short_name: 'Map D',
            desc: '7 families',
            players: [2, 3, 4, 5],
          },
          {
            sym: :map_e,
            short_name: 'Map E',
            desc: '7 families',
            players: [2, 3, 4, 5],
          },
          {
            sym: :map_f,
            short_name: 'Map F',
            desc: '7 families',
            players: [2, 3, 4, 5],
          },
          {
            sym: :power_visible,
            short_name: 'Powers visible',
            desc: 'Next powers are visible since the beginning.',
          },
        ].freeze
      end
    end
  end
end
