# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapUKLimitedCustomization
        def map_uk_limited_game_tiles(tiles)
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('205')
          tiles.delete('206')

          tiles
        end

        def map_uk_limited_layout
          :pointy
        end

        def map_uk_limited_game_location_names
          {
            'B3' => 'Glasgow',
            'B5' => 'Edinburgh',
            'C6' => 'Newcastle',
            'D7' => 'York',
            'E4' => 'Liverpool & Holyhead',
            'E6' => 'Manchester',
            'F5' => 'Birmingham',
            'F7' => 'Nottingham & Peterborough',
            'G4' => 'Bristol',
            'G6' => 'Northhampton',
            'H3' => 'Exeter',
            'H5' => 'Bournemouth',
            'H7' => 'London',
          }
        end

        # rubocop:disable Layout/LineLength
        def map_uk_limited_game_hexes
          {
            gray: {
              ['A2'] => 'junction;path=a:5,b:_0,terminal:1',
              ['A4'] => 'path=a:0,b:5',
              ['B1'] => 'junction;path=a:4,b:_0,terminal:1',
              ['B7'] => 'path=a:0,b:1',
              ['C2'] => 'path=a:3,b:4',
              ['C8'] => 'path=a:0,b:1',
              ['D3'] => 'path=a:3,b:4;path=a:4,b:5',
              ['F3'] => 'path=a:3,b:4;path=a:4,b:5',
              ['G2'] => 'path=a:4,b:5',
              ['H7'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50,loc:1.5;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0,terminal:1',
            },
            white: {
              %w[C4 D5 E8 F9 G8] => '',
              %w[D7 H3 H5] => 'town=revenue:0',
              ['F7'] => 'town=revenue:0;town=revenue:0',
              %w[C6 G4 G6] => 'city=revenue:0',
            },
            yellow: {
              %w[B5 E4] => 'city=revenue:0;city=revenue:0;label=OO',
              ['B3'] => 'city=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
              ['E6'] => 'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=B',
              ['F5'] => 'city=revenue:30;path=a:2,b:_0;path=a:4,b:_0;label=B',
            },
          }
        end
        # rubocop:enable Layout/LineLength

        def map_uk_limited_game_companies
          []
        end

        # DGN GFN PHX KKN SPX
        def map_uk_limited_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:coordinates] = %w[F5 B5 B3 H7 E6][idx]
          end

          corps
        end

        def map_uk_limited_game_cash
          { 2 => 850, 3 => 575, 4 => 425 }
        end

        def map_uk_limited_game_cert_limit
          { 2 => 20, 3 => 13, 4 => 11 }
        end

        def map_uk_limited_game_capitalization
          :full
        end

        def map_uk_limited_game_market
          self.class::MARKET_2D
        end

        def map_uk_limited_custom_depot
          GSystem18::UKDepot
        end

        def map_uk_limited_game_trains(trains)
          # don't use 8 trains
          trains.delete(find_train(trains, '8'))
          find_train(trains, '4')[:rusts_on] = 'D'
          # udpate quantities
          find_train(trains, '2')[:num] = 5
          find_train(trains, '3')[:num] = 4
          find_train(trains, '4')[:num] = 3
          find_train(trains, '5')[:num] = 2
          find_train(trains, '6')[:num] = 1
          find_train(trains, 'D')[:num] = 10
          trains
        end

        def map_uk_limited_game_phases
          self.class::S18_FULLCAP_PHASES
        end

        def map_uk_limited_constants
          redef_const(:CURRENCY_FORMAT_STR, '£%s')
        end

        def map_uk_limited_or_round_finished
          return if @phase.name == 'D'

          @depot.export_all!(@phase.name)
          @phase.buying_train!(nil, @depot.upcoming.first, self)
        end
      end
    end
  end
end
