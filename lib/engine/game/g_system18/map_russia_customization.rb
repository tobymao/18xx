# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapRussiaCustomization
        MOSCOW_HEX = 'C8'
        ST_PETERSBERG_HEX = 'A6'
        KIEV_HEX = 'E4'
        MY_HEX = 'B9'
        MR_HEX = 'D9'
        NATIONAL_CORP = 'SPX'

        def map_russia_game_tiles(tiles)
          tiles.merge!({
                         '637' =>
                         {
                           'count' => 1,
                           'color' => 'green',
                           'code' => 'city=revenue:50,loc:0.5;city=revenue:50,loc:2.5;city=revenue:50,loc:4.5;'\
                                     'path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;'\
                                     'path=a:2,b:_1;path=a:_1,b:3;label=M',
                         },
                         '638' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M',
            },
                         '641' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=S',
            },
                       })
        end

        def map_russia_layout
          :pointy
        end

        def map_russia_game_location_names
          {
            'A6' => 'St Petersberg',
            'B3' => 'Riga',
            'C2' => 'Kaunas & Vilnius',
            'C4' => 'Vitebsk & Daugavpils',
            'C6' => 'Smolensk',
            'C8' => 'Moscow',
            'C10' => 'Nizhny Novgorod',
            'C12' => 'Siberia',
            'D1' => 'Poland',
            'D3' => 'Minsk & Pinsk',
            'D7' => 'Tula & Orel',
            'D11' => 'Simbirsk & Penza',
            'E4' => 'Kiev',
            'E8' => 'Voronezh',
            'E12' => 'Saratov',
            'F7' => 'Kharkov',
            'F11' => 'Tsaritsyn',
          }
        end

        def map_russia_game_hexes
          {
            gray: {
              %w[A2 B1] => 'path=a:4,b:5',
              %w[C4] => 'town=revenue:10;town=revenue:10;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_1;path=a:2,b:_1',
              %w[F3] => 'path=a:2,b:3;path=a:4,b:3',
              %w[F13] => 'path=a:1,b:2',
            },

            red: {
              %w[C12] => 'offboard=revenue:yellow_20|green_40|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
              %w[D1] => 'offboard=revenue:yellow_30|green_40|brown_50;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
            green: {
              %w[A6] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=S',
            },
            white: {
              %w[A4 B11 D5 D9 E2 E6 E10 F9] => '',
              %w[B9] => 'upgrade=cost:20,terrain:river',
              %w[F5] => 'upgrade=cost:40,terrain:river',
              %w[B3 C6 E8 E12 F7 F11] => 'city',
              %w[C10] => 'city=revenue:0;upgrade=cost:20,terrain:river',
              %w[C2 D3 D7 D11] => 'town=revenue:0;town=revenue:0',
            },
            yellow: {
              %w[B5] => 'path=a:0,b:3',
              %w[B7] => 'path=a:2,b:5',
              %w[C8] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=M',
              %w[E4] => 'city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=OO',
            },
          }
        end

        def map_russia_game_companies
          [
            {
              name: 'Tsarskoye Selo Railway',
              sym: 'TS',
              value: 20,
              revenue: 10,
              max_price: 30,
              desc: 'No special abilities.',
              color: nil,
            },
            {
              name: 'Moscow - Yaroslavl Railway',
              sym: 'MY',
              value: 40,
              revenue: 20,
              max_price: 60,
              desc: 'When owned by a corporation, they gain 10₽ extra revenue for '\
                    'each of their routes that include Moscow',
              abilities: [
                {
                  type: 'hex_bonus',
                  owner_type: 'corporation',
                  hexes: [MOSCOW_HEX],
                  amount: 10,
                },
                {
                  type: 'blocks_hexes',
                  owner_type: 'player',
                  hexes: [MY_HEX],
                },
              ],
              color: nil,
            },
            {
              name: 'Moscow - Ryazan Railway',
              sym: 'MR',
              value: 50,
              revenue: 25,
              max_price: 75,
              desc: 'When owned by a corporation, they gain 10₽ extra revenue for '\
                    'each of their routes that include Moscow',
              abilities: [
                {
                  type: 'hex_bonus',
                  owner_type: 'corporation',
                  hexes: [MOSCOW_HEX],
                  amount: 10,
                },
                {
                  type: 'blocks_hexes',
                  owner_type: 'player',
                  hexes: [MR_HEX],
                },
              ],
              color: nil,
            },
          ]
        end

        def map_russia_minor_corporations
          [
            {
              sym: 'RO',
              name: 'Riga-Orel Railway',
              logo: '1861/RO',
              simple_logo: '1861/RO.alt',
              float_percent: 100,
              always_market_price: true,
              tokens: [0],
              type: 'minor',
              coordinates: 'B3',
              shares: [100],
              max_ownership_percent: 100,
              color: '#009595',
            },
            {
              sym: 'KB',
              name: 'Kiev-Brest Railway',
              logo: '1861/KB',
              simple_logo: '1861/KB.alt',
              float_percent: 100,
              always_market_price: true,
              tokens: [0],
              shares: [100],
              max_ownership_percent: 100,
              type: 'minor',
              coordinates: 'E4',
              city: 0,
              color: '#4cb5d2',
            },
            {
              sym: 'KK',
              name: 'Kiev-Kursk Railway',
              logo: '1861/KK',
              simple_logo: '1861/KK.alt',
              float_percent: 100,
              always_market_price: true,
              tokens: [0],
              shares: [100],
              max_ownership_percent: 100,
              type: 'minor',
              coordinates: 'E4',
              city: 1,
              color: '#0097df',
            },
            {
              sym: 'SPW',
              name: 'St. Petersburg Warsaw',
              logo: '1861/SPW',
              simple_logo: '1861/SPW.alt',
              float_percent: 100,
              always_market_price: true,
              tokens: [0],
              shares: [100],
              max_ownership_percent: 100,
              type: 'minor',
              coordinates: 'A6',
              city: 0,
              color: '#0189d1',
            },
            {
              sym: 'KR',
              name: 'Kharkiv-Rostov Railway',
              logo: '1861/KR',
              simple_logo: '1861/KR.alt',
              float_percent: 100,
              always_market_price: true,
              tokens: [0],
              shares: [100],
              max_ownership_percent: 100,
              type: 'minor',
              coordinates: 'F7',
              color: '#772282',
            },
            {
              sym: 'N',
              name: 'Nikolaev Railway',
              logo: '1861/N',
              simple_logo: '1861/N.alt',
              float_percent: 100,
              always_market_price: true,
              tokens: [0],
              shares: [100],
              max_ownership_percent: 100,
              type: 'minor',
              coordinates: MOSCOW_HEX,
              city: 1,
              color: '#d30869',
            },
            {
              sym: 'MK',
              name: 'Moscow-Kursk Railway',
              logo: '1861/M-K',
              simple_logo: '1861/M-K.alt',
              float_percent: 100,
              always_market_price: true,
              tokens: [0],
              shares: [100],
              max_ownership_percent: 100,
              type: 'minor',
              coordinates: MOSCOW_HEX,
              city: 0,
              color: '#d75500',
            },
            {
              sym: 'MNN',
              name: 'Moscow-Nizhnii Novgorod',
              logo: '1861/MNN',
              simple_logo: '1861/MNN.alt',
              float_percent: 100,
              always_market_price: true,
              tokens: [0],
              shares: [100],
              max_ownership_percent: 100,
              type: 'minor',
              coordinates: MOSCOW_HEX,
              city: 2,
              color: '#ef4223',
            },
          ]
        end

        # DGN GFN PHX KKN SPX
        def map_russia_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:float_percent] = 20
            c[:always_market_price] = true
            c[:type] = 'major'
            c[:coordinates] = [nil, nil, nil, nil, 'A6'][idx]
            c[:city] = [nil, nil, nil, nil, 1][idx]
            c[:type] = %w[major major major major national][idx]
          end
          find_corp(corps, 'SPX')[:tokens] = [0, 0, 0, 0, 0]
          minors = map_russia_minor_corporations
          minors.concat(corps)
        end

        def map_russia_game_cash
          { 2 => 315, 3 => 210 }
        end

        def map_russia_game_cert_limit
          { 2 => 16, 3 => 11 }
        end

        def map_russia_game_capitalization
          :incremental
        end

        def map_russia_game_market
          self.class::MARKET_1D
        end

        def map_russia_game_trains(trains)
          # don't use D trains
          trains.delete(find_train(trains, 'D'))
          find_train(trains, '4')[:rusts_on] = '8'
          # udpate
          find_train(trains, '2')[:num] = 6
          find_train(trains, '2')[:distance] = [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                                                { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }]
          find_train(trains, '3')[:num] = 5
          find_train(trains, '3')[:distance] = [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                                                { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }]
          find_train(trains, '4')[:num] = 2
          find_train(trains, '4')[:distance] = [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                                                { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }]
          find_train(trains, '5')[:num] = 2
          find_train(trains, '5')[:distance] = [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 },
                                                { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }]
          find_train(trains, '6')[:num] = 2
          find_train(trains, '6')[:distance] = [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6 },
                                                { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }]
          find_train(trains, '8')[:num] = 10
          find_train(trains, '8')[:events] = [{ 'type' => 'close_companies' }]
          find_train(trains, '8')[:distance] = [{ 'nodes' => %w[city offboard town], 'pay' => 8, 'visit' => 8 },
                                                { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }]
          trains
        end

        def map_russia_game_phases
          [
            {
              name: '2',
              train_limit: { minor: 2 },
              tiles: [:yellow],
              operating_rounds: 2,
            },
            {
              name: '3',
              on: '3',
              train_limit: { minor: 2, major: 4 },
              tiles: %i[yellow green],
              operating_rounds: 2,
              status: %w[can_buy_companies can_merge],
            },
            {
              name: '4',
              on: '4',
              train_limit: { minor: 1, major: 3 },
              tiles: %i[yellow green],
              operating_rounds: 2,
              status: %w[can_buy_companies can_merge can_start_major],
            },
            {
              name: '5',
              on: '5',
              train_limit: { minor: 1, major: 3 },
              tiles: %i[yellow green brown],
              operating_rounds: 2,
              status: %w[can_buy_companies can_merge can_start_major],
            },
            {
              name: '6',
              on: '6',
              train_limit: { minor: 1, major: 2 },
              tiles: %i[yellow green brown],
              operating_rounds: 2,
              status: %w[can_buy_companies can_merge can_start_major],
            },
            {
              name: '8',
              on: '8',
              train_limit: { minor: 0, major: 2 },
              tiles: %i[yellow green brown gray],
              status: %w[can_merge can_start_major],
              operating_rounds: 2,
            },
          ]
        end

        def map_russia_constants
          redef_const(:CURRENCY_FORMAT_STR, '%s₽')
          redef_const(:HOME_TOKEN_TIMING, :par)
          redef_const(:HOME_TOKEN_TIMING, :par)
          redef_const(:STATUS_TEXT,
                      {
                        'can_buy_companies' =>
                        ['Can Buy Companies', 'All corporations can buy companies from players'],
                        'can_merge' =>
                        ['Can Merge/Convert Minors',
                         'May form a major corporation by converting a minor or merging two connected minors'],
                        'can_start_major' =>
                        ['Can Start a Major', 'May start a major corporation directly'],
                      })
          redef_const(:GAME_END_CHECK, { final_phase: :one_more_full_or_set })
        end

        def map_russia_init_round
          Engine::Round::Auction.new(self, [
            GSystem18::Step::ConsecutiveAuction,
          ])
        end

        def map_russia_stock_steps
          [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            GSystem18::Step::HomeToken,
            GSystem18::Step::BuySellParBidMerge,
          ]
        end

        def map_russia_setup
          # place sphinx home token
          spx = corporation_by_id('SPX')
          hex = hex_by_id(spx.coordinates)
          tile = hex.tile
          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(spx) } || cities.first
          token = spx.find_token_by_type
          @log << "#{spx.name} places a token on #{hex.name}"
          city.place_token(spx, token)
        end

        def map_russia_home_token_locations(corporation)
          return [] unless corporation.type == :major

          # find hexes with open slots
          hexes.select do |hex|
            hex.tile.cities.any? { |c| c.tokenable?(corporation, free: true) }
          end
        end

        def map_russia_check_other(route)
          if route.visited_stops.count { |s| s.hex.id == MOSCOW_HEX } > 1
            raise GameError, 'Cannot visit Moscow more than once with the same train'
          end
          if route.visited_stops.count { |s| s.hex.id == KIEV_HEX } > 1
            raise GameError, 'Cannot visit Moscow more than once with the same train'
          end
          return unless route.visited_stops.count { |s| s.hex.id == ST_PETERSBERG_HEX } > 1

          raise GameError, 'Cannot visit St Petersberg more than once with the same train'
        end

        def map_russia_bonuses(route, stops)
          extra = 0
          route.corporation.companies.each do |company|
            abilities(company, :hex_bonus) do |ability|
              extra += stops.map { |s| s.hex.id }.uniq&.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
            end
          end

          extra
        end

        def map_russia_extra_revenue_for(route, stops)
          map_russia_bonuses(route, stops)
        end

        def map_russia_extra_revenue_str(route)
          bonus = map_russia_bonuses(route, route.stops)
          bonus.zero? ? '' : ' + Moscow'
        end

        def map_russia_must_buy_train?(_entity)
          false
        end

        def map_russia_no_trains(entity)
          nationalize(entity, corporation_by_id(NATIONAL_CORP))
        end

        def map_russia_or_set_finished
          depot.export! if phase.name.to_i < 8
          # fix the fact turn has already advanced by the time we get here
          @turn -= 1
          game_end_check
          @turn += 1
        end

        def map_russia_can_issue_shares_for_train?(entity)
          entity.corporation? && entity.type == :major && entity.trains.empty? && entity.cash < @depot.min_depot_price
        end
      end
    end
  end
end
