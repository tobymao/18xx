# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapPolandCustomization
        POLAND_REGION_HEXES = {
          'Prussia' => %w[A3 A5 B2 B4 B6 C3 C5 D2 D4 E3 E5],
          'Russia' => %w[B8 C7 C9 D6 D8 D10],
          'Austria' => %w[E7 E9],
        }.freeze

        POLAND_CORP_REGIONS = {
          'SPX' => 'Prussia',
          'PHX' => 'Prussia',
          'GFN' => 'Russia',
          'DGN' => 'Russia',
          'KKN' => 'Austria',
        }.freeze

        POLAND_EWNS_BONUS = [0, 0, 0, 50, 50, 50, 60].freeze

        def map_poland_game_tiles(tiles)
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('59')
          tiles.delete('64')
          tiles.delete('65')
          tiles.delete('66')
          tiles.delete('67')
          tiles.delete('68')
          tiles.delete('205')
          tiles.delete('206')
          tiles['8'] = 4
          tiles.merge!({
                         'X1' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=D',
            },
                         'X2' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:50,loc:0.5;city=revenue:50,loc:2.5;city=revenue:50,loc:4.5;'\
                        'path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;'\
                        'path=a:2,b:_1;path=a:_1,b:3;label=Wa',

            },
                         'X3' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Wa',

            },
                         'X4' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:100,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                        'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Wa',

            },
                         'X5' =>
              {
                'count' => 2,
                'color' => 'gray',
                'code' => 'city=revenue:70,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                          'path=a:5,b:_0;label=B',
              },
                       })
        end

        def map_poland_layout
          :pointy
        end

        def map_poland_game_location_names
          {
            'A3' => '(Prussia)',
            'A5' => 'Danzig',
            'A7' => 'Königsberg',
            'B2' => 'Stettin',
            'B4' => 'Bromberg',
            'B6' => 'Ebling & Thorn',
            'B8' => '(Russia)',
            'B10' => 'St Petersburg',
            'C1' => 'Berlin',
            'C3' => 'Posen',
            'C7' => 'Warsaw',
            'C11' => 'Moscow',
            'D4' => 'Breslau',
            'D6' => 'Lodz',
            'D8' => 'Radom & Deblin',
            'D10' => 'Lublin',
            'E5' => 'Kattowitz',
            'E7' => 'Krakau',
            'E9' => '(Austria)',
            'E11' => 'Kiev',
            'F4' => 'Wien',
            'F10' => 'N-S and E-W bonuses',
          }
        end

        # rubocop:disable Layout/LineLength
        def map_poland_game_hexes
          {
            gray: {
              %w[F6 F8] => 'path=a:2,b:3',
              %w[F10] => 'offboard=revenue:yellow_0|green_0|brown_50|gray_60',
            },

            red: {
              %w[A7] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:0,b:_0;path=a:5,b:_0;label=N',
              %w[B10] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0;path=a:1,b:_0;label=E',
              %w[C1] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=W',
              %w[C11] => 'offboard=revenue:yellow_20|green_30|brown_60|gray_90;path=a:0,b:_0;path=a:1,b:_0;label=E',
              %w[E11] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:1,b:_0;path=a:2,b:_0;label=E',
              %w[F4] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70;path=a:2,b:_0;path=a:3,b:_0;label=S',
            },
            white: {
              %w[A3] => '',
              %w[B8] => 'border=type:province,color:red,edge:1',
              %w[C9 D2] => 'upgrade=cost:20,terrain:water',
              %w[E9] => 'upgrade=cost:20,terrain:water;border=type:province,color:red,edge:2;border=type:province,color:red,edge:3',
              %w[C5] => 'upgrade=cost:40,terrain:water;border=type:province,color:red,edge:4;border=type:province,color:red,edge:5',
              %w[D8] => 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:water;border=type:province,color:red,edge:0;border=type:province,color:red,edge:5',
              %w[B6] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:water;border=type:province,color:red,edge:4;border=type:province,color:red,edge:5',
              %w[E3] => 'upgrade=cost:80,terrain:mountain',
              %w[B2 B4] => 'city=revenue:0',
              %w[A5] => 'city=revenue:0;future_label=label:D,color:green',
              %w[D10] => 'city=revenue:0;border=type:province,color:red,edge:0',
              %w[E5] => 'city=revenue:0;border=type:province,color:red,edge:4',
              %w[D6] => 'city=revenue:0;border=type:province,color:red,edge:2;border=type:province,color:red,edge:1;border=type:province,color:red,edge:0',
              %w[C3] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            },
            yellow: {
              %w[C7] => 'city=revenue:40,loc:0;city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;border=type:province,color:red,edge:2;border=type:province,color:red,edge:1;label=Wa',
              %w[D4] => 'city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;border=type:province,color:red,edge:4;label=B',
              %w[E7] => 'city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;border=type:province,color:red,edge:1;border=type:province,color:red,edge:2;border=type:province,color:red,edge:3;label=B',
            },
          }
        end
        # rubocop:enable Layout/LineLength

        def map_poland_game_companies
          [
            {
              name: 'DGN Charter',
              sym: 'DGN',
              value: 0,
              revenue: 0,
              desc: 'Allows opening DGN corporation',
              color: '#50c878',
            },
            {
              name: 'GFN Charter',
              sym: 'GFN',
              value: 0,
              revenue: 0,
              desc: 'Allows opening GFN corporation',
              color: '#999999',
            },
            {
              name: 'PHX Charter',
              sym: 'PHX',
              value: 0,
              revenue: 0,
              desc: 'Allows opening PHX corporation',
              color: '#ff7518',
              text_color: 'black',
            },
            {
              name: 'KKN Charter',
              sym: 'KKN',
              value: 0,
              revenue: 0,
              desc: 'Allows opening KKN corporation',
              color: '#0096ff',
            },
            {
              name: 'SPX Charter',
              sym: 'SPX',
              value: 0,
              revenue: 0,
              desc: 'Allows opening SPX corporation',
              color: '#fafa33',
              text_color: 'black',
            },
          ]
        end

        # DGN GFN PHX KKN SPX
        def map_poland_game_corporations(corps)
          corps.each_with_index do |c, idx|
            c[:float_percent] = 20
            c[:always_market_price] = true
            c[:coordinates] = %w[C7 C7 D4 E7 B2][idx]
            c[:city] = [0, 2, nil, nil, nil][idx]
          end
          corps
        end

        def map_poland_game_cash
          { 2 => 480, 3 => 320, 4 => 240 }
        end

        def map_poland_game_cert_limit
          { 2 => 20, 3 => 13, 4 => 10 }
        end

        def map_poland_game_capitalization
          :incremental
        end

        def map_poland_game_market
          self.class::MARKET_1D
        end

        def map_poland_game_trains(trains)
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

        def map_poland_game_phases
          phases = self.class::S18_INCCAP_PHASES
          phases[0][:status] = ['local_tokens'] # 2
          phases[1][:status] = ['local_tokens'] # 3
          phases[2][:status] = ['local_tokens'] # 4
          phases
        end

        def map_poland_constants
          redef_const(:CURRENCY_FORMAT_STR, 'zł%s')
          redef_const(:STATUS_TEXT, { 'local_tokens' => ['Local Tokens', 'Can only token in home country'] })
        end

        def map_poland_company_header(_company)
          'CHARTER'
        end

        def map_poland_init_round
          map_poland_new_parliament_round
        end

        def map_poland_new_parliament_round
          @log << "-- Parliament Round #{@turn} -- "
          GSystem18::Round::Parliament.new(self, [
            GSystem18::Step::CharterAuction,
          ])
        end

        def map_poland_next_round!
          @round =
            case @round
            when Engine::Round::Stock
              map_poland_stock_round_finished
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                map_poland_new_parliament_round
              end
            else # Parliament Round
              init_round_finished
              new_stock_round
            end
        end

        # remove un-excersized charters from players
        def map_poland_stock_round_finished
          @players.each do |player|
            player.companies.dup.each do |c|
              @log << "Right to open #{c.sym} lapses for #{player.name}"
              player.companies.delete(c)
              c.owner = nil
            end
          end
        end

        def map_poland_can_par?(corporation, entity)
          !corporation.ipoed && entity.companies.find { |c| c.sym == corporation.name }
        end

        def map_poland_after_par(corporation)
          entity = corporation.owner

          company = entity.companies.find { |c| c.sym == corporation.name }
          raise GameError, 'Logic error, no matching company found' unless company

          entity.companies.delete(company)
          company.close!
        end

        def map_poland_tokener_check_connected(entity, _city, hex)
          return true if map_poland_legal_token_hex?(entity, hex)

          region = POLAND_CORP_REGIONS[entity&.name]
          raise GameError, "#{entity.name} can only place tokens in #{region} until phase 5"
        end

        def map_poland_tokener_available_hex(entity, hex)
          map_poland_legal_token_hex?(entity, hex)
        end

        def map_poland_legal_token_hex?(entity, hex)
          return true unless @phase.name.to_i < 5

          region = POLAND_CORP_REGIONS[entity&.name]
          POLAND_REGION_HEXES[region].include?(hex&.id)
        end

        def map_poland_extra_revenue_for(_route, stops)
          map_poland_east_west_north_south_bonus(stops)[:revenue]
        end

        def map_poland_extra_revenue_str(route)
          bonus = map_poland_east_west_north_south_bonus(route.stops)[:description]
          bonus ? " + #{bonus}" : ''
        end

        def map_poland_east_west_north_south_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.tile.label&.to_s == 'E' }
          west = stops.find { |stop| stop.tile.label&.to_s == 'W' }
          north = stops.find { |stop| stop.tile.label&.to_s == 'N' }
          south = stops.find { |stop| stop.tile.label&.to_s == 'S' }

          if east && west
            bonus[:revenue] += POLAND_EWNS_BONUS[@phase.name.to_i - 2]
            bonus[:description] = 'E/W'
          end

          if north && south
            bonus[:revenue] += POLAND_EWNS_BONUS[@phase.name.to_i - 2]
            bonus[:description] = 'N/S'
          end

          bonus
        end

        # FIXME: add reopen! method to Engine::Company
        #
        # open company associated with closed corporation
        # def map_poland_close_corporation_extra(corporation)
        #  company = companies.find { |c| c.sym == corporation.name }
        #  company.reopen!
        # end
      end
    end
  end
end
