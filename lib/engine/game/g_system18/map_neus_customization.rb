# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapNeusCustomization
        def map_neus_game_tiles(tiles)
          tiles.delete('5')
          tiles.delete('6')
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('205')
          tiles.delete('206')
          tiles.delete('619')
          tiles.merge!({
                         '54' => 1,
                         '62' => 1,
                         'X1' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
              'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
            },
                         'X2' =>
              {
                'count' => 1,
                'color' => 'gray',
                'code' =>
                'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=NY',
              },
                       })

          tiles
        end

        def map_neus_game_location_names
          {
            'B3' => 'Chicago',
            'B5' => 'Detroit & Cleveland',
            'B7' => 'Erie',
            'B11' => 'Boston',
            'C10' => 'New York City',
            'D9' => 'Washington DC',
          }
        end

        def map_neus_game_hexes
          {
            gray: {
              ['A6'] => 'path=a:0,b:5',
              ['A2'] => 'path=a:4,b:5',
              ['A4'] => 'path=a:1,b:5',
              ['A8'] => 'path=a:0,b:5;path=a:0,b:4',
              ['A10'] => 'path=a:0,b:5;path=a:1,b:4',
              ['A12'] => 'path=a:0,b:1',

              ['D3'] => 'path=a:3,b:4',
              ['D11'] => 'path=a:0,b:1',
              %w[E8 E10] => 'path=a:2,b:3',
              ['B1'] => 'junction;path=a:4,b:_0,terminal:1',
              ['C2'] => 'junction;path=a:3,b:_0,terminal:1',
            },
            blue: {
              ['C12'] => 'junction;path=a:2,b:_0,terminal:1',

            },
            white: {
              %w[B7 C4] => 'city',
              %w[C6] => 'town=revenue:0;town=revenue:0;upgrade=cost:120,terrain:mountain',
              %w[C8] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
              %w[B9 D5] => 'upgrade=cost:40,terrain:mountain',
              ['D7'] => 'upgrade=cost:120,terrain:mountain',
            },
            yellow: {
              ['B3'] => 'city=revenue:30;path=a:2,b:_0;path=a:4,b:_0;label=B',
              ['B5'] => 'city=revenue:0;city=revenue:0;label=OO',
              ['D9'] => 'city=revenue:30;city=revenue:0;path=a:2,b:_0;label=OO',
              ['B11'] => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;label=B',
              ['C10'] => 'city=revenue:40;city=revenue:40;path=a:2,b:_0;label=NY',
              ['I15'] => 'city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B',

            },
          }
        end

        def map_neus_game_companies
          []
        end

        def map_neus_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:coordinates] = %w[B7 D9 B5 C10 B11][idx]
          end

          corps
        end

        def map_neus_game_cash
          { 2 => 850, 3 => 575 }
        end

        def map_neus_game_cert_limit
          { 2 => 20, 3 => 13 }
        end

        def map_neus_game_capitalization
          :full
        end

        def map_neus_game_market
          self.class::MARKET_2D
        end

        def map_neus_game_trains(trains)
          # don't use 8 trains
          trains.delete(find_train(trains, '8'))
          find_train(trains, '4')[:rusts_on] = 'D'
          # udpate quantities
          find_train(trains, '2')[:num] = 4
          find_train(trains, '3')[:num] = 3
          find_train(trains, '4')[:num] = 2
          find_train(trains, '5')[:num] = 2
          find_train(trains, '6')[:num] = 1
          trains
        end

        def map_neus_game_phases
          self.class::S18_FULLCAP_PHASES
        end

        def map_neus_constants; end
      end
    end
  end
end
