# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'tiles'
require_relative '../g_1858/game'

module Engine
  module Game
    module G1858India
      class Game < G1858::Game
        include_meta(G1858India::Meta)
        include Entities
        include Map
        include Tiles

        CURRENCY_FORMAT_STR = '£%s'
        BANK_CASH = 16_000
        STARTING_CASH = { 3 => 665, 4 => 500, 5 => 400, 6 => 335 }.freeze
        CERT_LIMIT = { 3 => 27, 4 => 20, 5 => 16, 6 => 13 }.freeze

        TRAIN_COUNTS = {
          '2H' => 8,
          '4H' => 7,
          '6H' => 5,
          '5E' => 4,
          '6E' => 3,
          '7E' => 20,
          '5D' => 10,
        }.freeze

        def game_trains
          unless @game_trains
            @game_trains = super.map(&:dup)
            # Add the 1M variant to the 2H train.
            @game_trains.first['variants'] =
              [
                {
                  name: '1M',
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                             { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                  price: 70,
                },
              ]
          end
          @game_trains
        end

        def num_trains(train)
          TRAIN_COUNTS[train[:name]]
        end

        def game_phases
          unless @game_phases
            @game_phases = super.map(&:dup)
            @game_phases.first[:status] = %w[yellow_privates narrow_gauge]
          end
          @game_phases
        end
      end
    end
  end
end
