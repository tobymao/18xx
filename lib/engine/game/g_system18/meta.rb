# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module GSystem18
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_DESIGNER = 'Scott Petersen'
        GAME_LOCATION = 'Various'
        GAME_PUBLISHER = :all_aboard_games

        GAME_INFO_URL = 'something'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :map_NEUS,
            short_name: 'Northeast US',
            desc: 'Map: Northeast United States',
            players: [2, 3],
            default: true,
          },
          {
            sym: :map_France,
            short_name: 'France',
            desc: 'Map: France',
            players: [2, 3, 4],
          },
        ].freeze

        MUTEX_RULES = [
          %i[map_NEUS map_France],
        ].freeze
      end
    end
  end
end
