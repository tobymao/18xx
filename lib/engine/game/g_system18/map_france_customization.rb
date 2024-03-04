# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapFranceCustomization
        # rubocop:disable Layout/LineLength
        def map_france_game_tiles(tiles)
          tiles.merge!({
                         'X2' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
              'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
            },
                         'X4' =>
              {
                'count' => 1,
                'color' => 'green',
                'code' =>
                'city=revenue:60,loc:5.5;city=revenue:60,loc:1.5;city=revenue:60,loc:3.5;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_2;label=P',
              },
                         'X5' =>
                {
                  'count' => 1,
                  'color' => 'brown',
                  'code' =>
                  'city=revenue:80,slots:2,loc:5.5;city=revenue:80,loc:2.5;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_0;path=a:5,b:_0;label=P',
                },

                       })
        end

        # rubocop:enable Layout/LineLength
        #
        def map_france_layout
          :pointy
        end

        def map_france_game_location_names
          {
            'B4' => 'London',
            'B6' => 'Lille',
            'C3' => 'Caen',
            'C5' => 'Paris',
            'C9' => 'Strasbourg',
            'C11' => 'Stuttgart',
            'D2' => 'Nantes',
            'D4' => 'Tours & Poitiers',
            'D8' => 'Dijon & Geneva',
            'E3' => 'Bordeaux',
            'E7' => 'Lyon',
            'F4' => 'Toulouse',
            'F6' => 'Montpelier',
            'F8' => 'Marseille',
            'F10' => 'Monaco',
            'G5' => 'Barcelona',
          }
        end

        def map_france_game_hexes
          {
            gray: {
              %w[A5] => 'town=revenue:0;path=a:0,b:_0;path=a:5,b:_0',
              %w[B8] => 'town=revenue:0;town=revenue:0;path=a:0,b:_0;path=a:1,b:_0;path=a:0,b:_1;path=a:5,b:_1',
              %w[C1] => 'town=revenue:0;path=a:4,b:_0;path=a:5,b:_0',
              %w[D10] => 'town=revenue:0;path=a:1,b:_0;path=a:2,b:_0',
              %w[E1 F2] => 'town=revenue:0;path=a:3,b:_0;path=a:4,b:_0',
              %w[E9] => 'town=revenue:0;town=revenue:0;path=a:0,b:_0;path=a:1,b:_0;path=a:1,b:_1;path=a:2,b:_1',
              %w[G9] => 'town=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            },

            red: {
              %w[B4] => 'offboard=revenue:green_40|brown_70;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
              %w[C11] => 'offboard=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0',
              %w[F10] => 'offboard=revenue:green_30|brown_40;path=a:1,b:_0;path=a:0,b:_0',
              %w[G5] => 'offboard=revenue:yellow_20|green_20|brown_40;path=a:2,b:_0;path=a:3,b:_0',
            },
            white: {
              %w[C3 C9 D2 E3 E7 F4 F6] => 'city',
              %w[C7 D6 E5] => 'town=revenue:0;town=revenue:0',
            },
            yellow: {
              ['B6'] => 'city=revenue:30;path=a:4,b:_0;label=B',
              ['C5'] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_1;path=a:5,b:_2;label=P',
              %w[D4 D8] => 'city=revenue:0;city=revenue:0;label=OO',
              ['F8'] => 'city=revenue:30;path=a:1,b:_0;label=B',
            },
          }
        end

        def map_france_game_companies
          []
        end

        def map_france_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:float_percent] = 20
            c[:always_market_price] = true
            c[:coordinates] = %w[C5 C5 C5 C9 E7][idx]
            c[:city] = [0, 1, 2, nil, nil][idx]
          end
          corps
        end

        def map_france_game_cash
          { 2 => 480, 3 => 320, 4 => 240 }
        end

        def map_france_game_cert_limit
          { 2 => 20, 3 => 13, 4 => 10 }
        end

        def map_france_game_capitalization
          :incremental
        end

        def map_france_game_market
          self.class::MARKET_1D
        end

        def map_france_game_trains(trains)
          # don't use D trains
          trains.delete(find_train(trains, 'D'))
          find_train(trains, '4')[:rusts_on] = '8'
          # udpate quantities
          find_train(trains, '2')[:num] = 4
          find_train(trains, '3')[:num] = 3
          find_train(trains, '4')[:num] = 2
          find_train(trains, '5')[:num] = 2
          find_train(trains, '6')[:num] = 1
          find_train(trains, '8')[:num] = 10
          trains
        end

        def map_france_game_phases
          self.class::S18_INCCAP_PHASES
        end

        def map_france_constants
          redef_const(:CURRENCY_FORMAT_STR, 'F%s')
        end
      end
    end
  end
end
