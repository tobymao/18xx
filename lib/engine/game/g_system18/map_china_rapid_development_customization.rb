# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapChinaRapidDevelopmentCustomization
        # rubocop:disable Layout/LineLength
        def map_china_rapid_development_game_tiles(tiles)
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('53')
          tiles.delete('61')
          tiles.delete('205')
          tiles.delete('206')
          tiles.merge!({
                         'X1' => {
                           'count' => 2,
                           'color' => 'yellow',
                           'code' => 'city=revenue:30;city=revenue:0;path=a:0,b:_0;label=OO',
                         },
                         'X2' => {
                           'count' => 1,
                           'color' => 'green',
                           'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;path=a:2,b:_2;path=a:_2,b:5;label=S',
                         },
                         'X3' => {
                           'count' => 1,
                           'color' => 'green',
                           'code' => 'city=revenue:40,loc:center;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:3;label=X',
                         },
                         'X4' => {
                           'count' => 1,
                           'color' => 'green',
                           'code' => 'city=revenue:40,loc:center;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:2;label=X',
                         },
                         'X5' => {
                           'count' => 1,
                           'color' => 'green',
                           'code' => 'city=revenue:40,loc:center;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:4;label=X',
                         },
                         'X6' => {
                           'count' => 1,
                           'color' => 'brown',
                           'code' => 'city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;path=a:2,b:_2;path=a:_2,b:5;label=S',
                         },
                         'X7' => {
                           'count' => 1,
                           'color' => 'brown',
                           'code' => 'city=revenue:50,loc:center;town=revenue:20,loc:3;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:2;path=a:_1,b:3;path=a:_1,b:4;label=X',
                         },
                         'X8' => {
                           'count' => 1,
                           'color' => 'gray',
                           'code' => 'city=revenue:60;city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;path=a:2,b:_2;path=a:_2,b:5;label=S',
                         },
                         'X9' => {
                           'count' => 1,
                           'color' => 'gray',
                           'code' => 'city=revenue:60,loc:center;town=revenue:20,loc:3;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:2;path=a:_1,b:3;path=a:_1,b:4;label=X',
                         },
                       })
        end
        # rubocop:enable Layout/LineLength

        def map_china_rapid_development_layout
          :flat
        end

        def map_china_rapid_development_game_location_names
          {
            'E3' => 'Changchun & Shenyang',
            'D4' => 'Beijing & Tianjin',
            'C5' => "Xi'an",
            'E5' => 'Dailan & Qingdao',
            'B6' => 'Lanzhou',
            'D6' => 'Jinan & Zhengzhou',
            'C7' => 'Chongqinq',
            'E7' => 'Nanjiing & Shanghai & Hangzhou',
            'B8' => 'Chengdu',
            'D8' => 'Wuhan & Changsha',
            'C9' => 'Guiyang & Nanning',
            'D10' => 'Guanzhou & Shenzhen',
          }
        end

        def map_china_rapid_development_game_hexes
          {
            gray: {
              %w[C3 B4] => 'path=a:0,b:5',
              %w[B6] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
              %w[A7 A9] => 'path=a:4,b:5',
            },
            blue: {
              %w[F4 F6 F8] => 'path=a:1,b:2',
              %w[E11] => 'path=a:2,b:3',
            },
            white: {
              %w[E1 D2 F2 E9 B10 C11] => '',
              %w[D6 C9] => 'town=revenue:0;town=revenue:0',
              %w[C5 C7 B8] => 'city=revenue:0',
              %w[D4 D10] => 'city=revenue:0;city=revenue:0;label=OO',
            },
            yellow: {
              %w[E3] => 'city=revenue:0,loc:center;town=revenue:10;path=a:2,b:_1;label=X',
              %w[E5] => 'city=revenue:0,loc:center;town=revenue:10;path=a:0,b:_1;label=X',
              %w[D8] => 'city=revenue:0,loc:center;town=revenue:10;path=a:4,b:_1;label=X',
              %w[E7] => 'city=revenue:0;city=revenue:0;city=revenue:0;label=S',
            },
          }
        end

        def map_china_rapid_development_game_companies
          []
        end

        # DGN GFN PHX KKN SPX
        def map_china_rapid_development_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:float_percent] = 20
            c[:always_market_price] = true
            c[:coordinates] = %w[D4 C7 B8 E7 D10][idx]
          end
          corps
        end

        def map_china_rapid_development_game_cash
          { 2 => 480, 3 => 320, 4 => 240 }
        end

        def map_china_rapid_development_game_cert_limit
          { 2 => 20, 3 => 13, 4 => 10 }
        end

        def map_china_rapid_development_game_capitalization
          :incremental
        end

        def map_china_rapid_development_game_market
          self.class::MARKET_1D
        end

        def map_china_rapid_development_game_trains(trains)
          # don't use D trains
          trains.delete(find_train(trains, 'D'))
          find_train(trains, '4')[:rusts_on] = '8'
          # udpate quantities
          find_train(trains, '2')[:num] = 3
          find_train(trains, '3')[:num] = 3
          find_train(trains, '4')[:num] = 2
          find_train(trains, '5')[:num] = 1
          find_train(trains, '6')[:num] = 1
          find_train(trains, '8')[:num] = 10
          trains
        end

        def map_china_rapid_development_game_phases
          self.class::S18_INCCAP_PHASES
        end

        def map_china_rapid_development_constants
          redef_const(:CURRENCY_FORMAT_STR, '¥%s')
          redef_const(:TILE_LAYS, [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }])
        end

        def map_china_rapid_development_operating_steps
          [
            GSystem18::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            GSystem18::Step::ChinaTrack,
            GSystem18::Step::Token,
            Engine::Step::Route,
            GSystem18::Step::ChinaDividend,
            Engine::Step::DiscardTrain,
            GSystem18::Step::BuyTrain,
          ]
        end
      end
    end
  end
end
