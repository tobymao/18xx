# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapScotlandCustomization
        GLASGOW_HEX = 'C5'

        # rubocop:disable Layout/LineLength
        def map_scotland_game_tiles(tiles)
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('205')
          tiles.delete('206')
          tiles.merge!({
                         'X1' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
              'city=revenue:50,loc:0.5;city=revenue:50,loc:2.5;city=revenue:50,loc:4.5;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_2;path=a:5,b:_2;label=G',
            },
                         'X2' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=G',
            },
                         'X3' =>
              {
                'count' => 1,
                'color' => 'gray',
                'code' =>
                'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=G',
              },
                       })

          tiles
        end
        # rubocop:enable Layout/LineLength

        def map_scotland_layout
          :pointy
        end

        def map_scotland_game_location_names
          {
            'A3' => 'Fort William',
            'A9' => 'Arbroath',
            'A11' => 'Aberdeen',
            'B6' => 'Stirling',
            'B8' => 'Perth & Dundee',
            'C3' => 'Greenock',
            'C5' => 'Glasgow',
            'C7' => 'Falkirk',
            'C9' => 'Edinburgh & Leith',
            'D4' => 'Ayr',
            'D6' => 'Motherwell',
            'D8' => 'Peebles & Selkirk',
            'D10' => 'Galashiels & Melrose',
            'D12' => 'Berwick',
            'F2' => 'Stranraer',
            'F6' => 'Dumfries & Kirkcudbright',
            'F8' => 'Carlisle',
          }
        end

        def map_scotland_game_hexes
          {
            red: {
              %w[A3] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_30;path=a:4,b:_0;path=a:5,b:_0',
              %w[A11] => 'city=revenue:yellow_30|green_40|brown_50|gray_50;path=a:1,b:_0',
              %w[D12] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:1,b:_0;path=a:2,b:_0',
            },
            gray: {
              %w[A9] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0',
              %w[B10] => 'junction;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
              %w[C3] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0',
              %w[D2] => 'junction;path=a:4,b:_0,terminal:1',
              %w[E1] => 'junction;path=a:5,b:_0,terminal:1',
              %w[E11] => 'path=a:1,b:2',
              %w[G3 G5] => 'path=a:2,b:3',
              %w[G9] => 'junction;path=a:2,b:_0,terminal:1',
            },
            white: {
              %w[E3 E9 F4] => '',
              %w[A5 B4] => 'upgrade=cost:80,terrain:mountain',
              %w[A7 E5 E7] => 'upgrade=cost:40,terrain:mountain',
              %w[D8 D10] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
              %w[F6] => 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:river',
              %w[B6 D4 D6 F2] => 'city',
              %w[C7] => 'city=revenue:0;border=type:water,cost:80,edge:3',
            },
            yellow: {
              %w[B8] => 'city=revenue:0;city=revenue:0;border=type:impassable,edge:5;border=type:water,cost:80,edge:0;label=OO',
              %w[C5] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2;label=G',
              %w[C9] => 'city=revenue:0;city=revenue:0;border=type:impassable,edge:2;label=OO',
              %w[C11] => 'path=a:1,b:5',
              %w[F8] => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;label=B',
            },
          }
        end

        def map_scotland_game_companies
          []
        end

        # DGN GFN PHX KKN SPX
        def map_scotland_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:coordinates] = %w[C5 F8 C5 C5 A11][idx]
          end
          find_corp(corps, 'DGN')[:city] = 0
          find_corp(corps, 'PHX')[:city] = 1
          find_corp(corps, 'KKN')[:city] = 2

          corps
        end

        def map_scotland_game_cash
          { 2 => 860, 3 => 575, 4 => 430 }
        end

        def map_scotland_game_cert_limit
          { 2 => 16, 3 => 11, 4 => 8 }
        end

        def map_scotland_game_capitalization
          :full
        end

        def map_scotland_game_market
          self.class::MARKET_2D
        end

        def map_scotland_game_trains(trains)
          # don't use 8 trains
          trains.delete(find_train(trains, '8'))
          find_train(trains, '4')[:rusts_on] = 'D'
          # udpate quantities
          find_train(trains, '2')[:num] = 4
          find_train(trains, '3')[:num] = 3
          find_train(trains, '4')[:num] = 2
          find_train(trains, '5')[:num] = 2
          find_train(trains, '6')[:num] = 1
          find_train(trains, 'D')[:num] = 10
          trains
        end

        def map_scotland_game_phases
          self.class::S18_FULLCAP_PHASES
        end

        def map_scotland_constants; end

        def map_scotland_check_other(route)
          return unless route.visited_stops.count { |s| s.hex.id == GLASGOW_HEX } > 1

          raise GameError, 'Cannot visit Glasgow more than once with the same train'
        end
      end
    end
  end
end
