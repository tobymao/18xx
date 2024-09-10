# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapBaseCustomization
        def map_base_game_tiles(tiles)
          tiles
        end

        def map_base_layout
          :pointy
        end

        def map_base_game_location_names
          {}
        end

        def map_base_game_hexes
          {
            white: {
              %w[A1 B2 A3 B4 A5] => 'city',
            },
          }
        end

        def map_base_game_companies
          []
        end

        def map_base_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:coordinates] = %w[A1 B2 A3 B4 A5][idx]
          end

          corps
        end

        def map_base_game_cash
          { 2 => 800, 3 => 500, 4 => 400, 5 => 300 }
        end

        def map_base_game_cert_limit
          { 2 => 20, 3 => 15, 4 => 10, 5 => 8 }
        end

        def map_base_game_capitalization
          :full
        end

        def map_base_game_market
          self.class::MARKET_2D
        end

        def map_base_game_trains(trains)
          find_train(trains, '4')[:rusts_on] = %w[8 D]
          trains
        end

        def map_base_game_phases
          base_phases = self.class::S18_FULLCAP_PHASES.dup
          base_phases.insert(base_phases.size - 1, {
                               name: '8',
                               on: '8',
                               train_limit: 2,
                               tiles: %i[yellow green brown gray],
                               operating_rounds: 2,
                             })
          base_phases
        end

        def map_base_constants; end
      end
    end
  end
end
