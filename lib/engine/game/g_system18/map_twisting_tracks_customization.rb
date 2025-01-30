# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapTwistingTracksCustomization
        TT_TC_COST = 25
        TT_TC_UPGRADE_TILES = %w[14 15 619].freeze

        # rubocop:disable Layout/LineLength
        def map_twisting_tracks_game_tiles(tiles)
          tiles.delete('1')
          tiles.delete('2')
          tiles.delete('5')
          tiles.delete('6')
          tiles.delete('7')
          tiles.delete('8')
          tiles.delete('9')
          tiles.delete('12')
          tiles.delete('13')
          tiles['14'] = 1
          tiles['15'] = 1
          tiles.delete('23')
          tiles.delete('24')
          tiles.delete('25')
          tiles.delete('26')
          tiles.delete('27')
          tiles.delete('28')
          tiles.delete('29')
          tiles.delete('39')
          tiles.delete('40')
          tiles.delete('41')
          tiles.delete('42')
          tiles.delete('43')
          tiles.delete('44')
          tiles.delete('45')
          tiles.delete('46')
          tiles.delete('47')
          tiles.delete('53')
          tiles.delete('55')
          tiles.delete('56')
          tiles['59'] = 4
          tiles.delete('61')
          tiles.delete('63')
          tiles.delete('69')
          tiles['619'] = 1
          tiles.merge!({
                         'X1' =>
                         {
                           'count' => 2,
                           'color' => 'gray',
                           'code' =>
                           'city=revenue:60,loc:5.5;city=revenue:60,loc:1.5;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:4,b:_1;label=OO',
                         },
                         'X2' =>
              {
                'count' => 2,
                'color' => 'pink',
                'code' =>
                'city=revenue:70,loc:5.5;city=revenue:70,loc:1.5;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:4,b:_1;label=OO',
              },
                         'X3' =>
                  {
                    'count' => 1,
                    'color' => 'purple',
                    'code' =>
                    'city=revenue:80,slots:2,loc:5.5;city=revenue:80,loc:1.5;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:4,b:_1;label=OO',
                  },
                         'X4' =>
                  {
                    'count' => 1,
                    'color' => 'purple',
                    'code' =>
                    'city=revenue:80,loc:5.5;city=revenue:80,slots:2,loc:1.5;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:4,b:_1;label=OO',
                  },
                         'X5' =>
                    {
                      'count' => 1,
                      'color' => 'orange',
                      'code' =>
                      'city=revenue:90,slots:2,loc:5.5;city=revenue:90,slots:2,loc:1.5;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:4,b:_1;label=OO',
                    },
                         'X6' =>
                      {
                        'count' => 1,
                        'color' => 'navy',
                        'code' =>
                        'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO',
                      },
                       })

          tiles
        end
        # rubocop:enable Layout/LineLength

        def map_twisting_tracks_layout
          :pointy
        end

        def map_twisting_tracks_game_location_names
          {
            'B5' => 'Linearia',
            'B7' => 'Vortex Vista',
            'B9' => 'Straightarrow Springs',
            'C4' => 'Twistopolis',
            'C6' => 'Mazeview',
            'C8' => 'Spiral Sands',
            'C10' => 'Wigglewood',
            'D3' => 'Straightford',
            'D5' => 'Helix Heights',
            'D7' => 'Tanglewood',
            'D9' => 'Orthoville',
            'E4' => 'Helix Harbor',
            'E6' => 'Parallel Piers',
            'E8' => 'Coilington',
          }
        end

        def map_twisting_tracks_game_hexes
          {
            gray: {
              ['A6'] => 'town=revenue:20;path=a:4,b:_0,a_lane:2.1;path=a:_0,b:0;path=a:5,b:4,b_lane:2.0',
              ['A8'] => 'town=revenue:20;path=a:1,b:0,a_lane:2.0;path=a:1,b:_0,a_lane:2.1;path=a:_0,b:5',

              ['A10'] => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:5',
              ['B11'] => 'path=a:2,b:0;path=a:1,b:5',
              ['C12'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:1',

              ['D11'] => 'town=revenue:20;path=a:0,b:_0,a_lane:2.1;path=a:_0,b:2;path=a:1,b:0,b_lane:2.0',
              ['E10'] => 'town=revenue:20;path=a:3,b:2,a_lane:2.0;path=a:3,b:_0,a_lane:2.1;path=a:_0,b:1',

              ['F3'] => 'town=revenue:20;path=a:3,b:_0;path=a:_0,b:4',
              ['F5'] => 'town=revenue:20;path=a:1,b:3;path=a:2,b:_0;path=a:_0,b:4',
              ['F7'] => 'path=a:2,b:4;path=a:1,b:3',
              ['F9'] => 'town=revenue:20;path=a:1,b:_0;path=a:_0,b:2',

              ['E2'] => 'town=revenue:20;path=a:3,b:_0;path=a:_0,b:4',

              ['D1'] => 'town=revenue:20;path=a:3,b:_0;path=a:_0,b:4',
              ['C2'] => 'town=revenue:20;path=a:0,b:4;path=a:3,b:_0;path=a:_0,b:5',
              ['B3'] => 'path=a:0,b:4;path=a:3,b:5',
              ['A4'] => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:5',
            },
            white: {
              %w[B5 B9 D3 D9 E6] => 'city',
            },
            yellow: {
              %w[B7 C4 C6 C8 C10 D5 D7 E4 E8] => 'city=revenue:0;city=revenue:0;label=OO',
            },
          }
        end

        def map_twisting_tracks_game_companies
          []
        end

        # DGN GFN PHX KKN SPX
        def map_twisting_tracks_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:coordinates] = %w[B5 B9 E6 D3 D9][idx]
          end
          corps
        end

        def map_twisting_tracks_game_cash
          { 2 => 1000, 3 => 700, 4 => 500 }
        end

        def map_twisting_tracks_game_cert_limit
          { 2 => 20, 3 => 13, 4 => 11 }
        end

        def map_twisting_tracks_game_capitalization
          :full
        end

        def map_twisting_tracks_game_market
          self.class::MARKET_2D
        end

        def map_twisting_tracks_game_trains(trains)
          # don't use 8 trains
          trains.delete(find_train(trains, '8'))
          find_train(trains, '4')[:rusts_on] = 'D'
          # udpate quantities
          find_train(trains, '2')[:num] = 4
          find_train(trains, '3')[:num] = 3
          find_train(trains, '4')[:num] = 2
          find_train(trains, '5')[:num] = 1
          find_train(trains, '5')[:rusts_on] = 'D-Purple'
          find_train(trains, '5')[:price] = 450
          find_train(trains, '6')[:num] = 1
          find_train(trains, '6')[:rusts_on] = 'D-Orange'
          find_train(trains, '6')[:price] = 450
          find_train(trains, 'D')[:num] = 1
          find_train(trains, 'D')[:price] = 600
          trains.append({
                          name: 'D-Pink',
                          distance: 999,
                          price: 600,
                          num: 1,
                          discount: { '5' => 200, '6' => 200, 'D' => 200 },
                        })
          trains.append({
                          name: 'D-Purple',
                          distance: 999,
                          price: 600,
                          num: 1,
                          discount: { '5' => 200, '6' => 200, 'D' => 200, 'D-Pink' => 200 },
                        })
          trains.append({
                          name: 'D-Orange',
                          distance: 999,
                          price: 600,
                          num: 1,
                          discount: { '6' => 200, 'D' => 200, 'D-Pink' => 200, 'D-Purple' => 200 },
                        })
          trains.append({
                          name: 'D-Navy',
                          distance: 999,
                          price: 600,
                          num: 1,
                          discount: { 'D' => 200, 'D-Pink' => 200, 'D-Purple' => 200, 'D-Orange' => 200 },
                        })
          trains
        end

        def map_twisting_tracks_game_phases
          [
            { name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
            {
              name: '3',
              on: '3',
              train_limit: 4,
              tiles: %i[yellow green],
              operating_rounds: 2,
            },
            {
              name: '4',
              on: '4',
              train_limit: 3,
              tiles: %i[yellow green],
              operating_rounds: 2,
            },
            {
              name: '5',
              on: '5',
              train_limit: 2,
              tiles: %i[yellow green brown],
              operating_rounds: 2,
            },
            {
              name: '6',
              on: '6',
              train_limit: 2,
              tiles: %i[yellow green brown],
              operating_rounds: 2,
            },
            {
              name: 'D',
              on: 'D',
              train_limit: 1,
              tiles: %i[yellow green brown gray],
              operating_rounds: 2,
            },
            {
              name: 'D-Pink',
              on: 'D-Pink',
              train_limit: 1,
              tiles: %i[yellow green brown gray pink],
              operating_rounds: 2,
            },
            {
              name: 'D-Purple',
              on: 'D-Purple',
              train_limit: 1,
              tiles: %i[yellow green brown gray pink purple],
              operating_rounds: 2,
            },
            {
              name: 'D-Orange',
              on: 'D-Orange',
              train_limit: 1,
              tiles: %i[yellow green brown gray pink purple orange],
              operating_rounds: 2,
            },
            {
              name: 'D-Navy',
              on: 'D-Navy',
              train_limit: 1,
              tiles: %i[yellow green brown gray pink purple orange navy],
              operating_rounds: 2,
            },
          ]
        end

        def map_twisting_tracks_constants
          redef_const(:COLOR_SEQUENCE, %i[white yellow green brown gray pink purple orange navy])
        end

        def map_twisting_tracks_setup
          # add "Ticket Counter" cube tokens
          corporations.each do |corp|
            cube = "/logos/System18/#{corp.id}_CUBE_TOKEN.svg"
            3.times do
              corp.tokens << Token.new(corp, price: TT_TC_COST, logo: cube, simple_logo: cube, type: :ticket_counter)
            end
          end
        end

        def tt_sole_tc_token(corp, city)
          city.tokens.any? { |t| t&.corporation == corp && t.type == :ticket_counter } &&
            city.tokens.none? { |t| t&.corporation == corp && t.type != :ticket_counter }
        end

        # Error if passing through more than one Ticket Counter token
        def map_twisting_tracks_check_other(route)
          visits = route.visited_stops
          return unless visits.size > 2

          corp = route.train.owner
          num_tickets = visits[1..-2].count { |stop| stop.city? && tt_sole_tc_token(corp, stop) }

          raise GameError, 'Can only pass through one ticket counter' if num_tickets > 1
        end

        # auto-add Ticket Counter token when upgrading any home tile from yellow to a two-slot tile
        def map_twisting_tracks_post_lay_tile(entity, tile)
          return unless TT_TC_UPGRADE_TILES.include?(tile.name)

          tc = entity.find_token_by_type(:ticket_counter)
          raise GameError, 'Cannot upgrade this tile (out of Ticket Counters)' unless tc

          tile.cities.first.place_token(entity, tc, check_tokenable: false)
          @log << "#{entity.name} places a Ticket Counter on tile"
          clear_graph_for_entity(entity)
        end

        # allow 2nd token on hex if it's a different type
        def map_twisting_tracks_token_same_hex?(entity, hex, token)
          hex_tokens = entity.tokens.select { |t| t.hex == hex }
          return false if hex_tokens.size != 1

          hex_tokens[0].type != token.type
        end
      end
    end
  end
end
