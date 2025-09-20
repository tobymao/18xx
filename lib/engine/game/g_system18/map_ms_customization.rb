# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapMsCustomization
        CORP_DEST = [
          { corp_hex: 'B5', corp_city: 0, dest: 'F1' }, # ATSF
          { corp_hex: 'B5', corp_city: 1, dest: 'F1' }, # MKT
          { corp_hex: 'C8', corp_city: 0, dest: 'F3' }, # MP
          { corp_hex: 'D9', corp_city: 0, dest: 'F3' }, # SSW
          { corp_hex: 'E8', corp_city: 0, dest: 'B11' }, # IC
          { corp_hex: 'F1', corp_city: 0, dest: 'G8' }, # SP
          { corp_hex: 'F3', corp_city: 0, dest: 'B1' }, # FWD
          { corp_hex: 'F3', corp_city: 1, dest: 'G8' }, # T&P
          { corp_hex: 'F9', corp_city: 0, dest: 'C8' }, # GMO
        ].freeze

        def map_ms_game_tiles(tiles)
          tiles['8'] += 3
          tiles['9'] += 1
          tiles.delete('12')
          tiles.delete('13')
          tiles.delete('205')
          tiles.delete('206')
          tiles['895'] = 2
          tiles['X1'] =
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
              'city=revenue:70,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
            }
          tiles
        end

        def map_ms_layout
          :pointy
        end

        def map_ms_game_location_names
          {
            'B1' => 'Denver',
            'B5' => 'Topeka & Kansas City',
            'B9' => 'Peoria & Springfield',
            'B11' => 'Chicago',
            'C2' => 'Wichita',
            'C8' => 'St Louis',
            'D3' => 'Oklahoma City',
            'D5' => 'Tulsa & Springfield',
            'D9' => 'Memphis',
            'E6' => 'Little Rock',
            'E8' => 'Jackson',
            'F1' => 'South-West',
            'F3' => 'Fort Worth & Dallas',
            'F5' => 'Marshall & Shreveport',
            'F7' => 'Vicksburg & Baton Rouge',
            'F9' => 'Mobile',
            'F11' => 'South-East',
            'G2' => 'Austin',
            'G4' => 'Houston',
            'G8' => 'New Orleans',
          }
        end

        def map_ms_game_hexes
          {
            gray: {
              %w[A4] => 'path=a:0,b:5',
              %w[A6] => 'path=a:0,b:5',
              %w[C0] => 'junction;path=a:4,b:_0,terminal:1',
              %w[G10] => 'junction;path=a:2,b:_0,terminal:1',
              %w[H3] => 'path=a:2,b:3',
              %w[H5] => 'junction;path=a:2,b:_0,terminal:1',
              %w[H9] => 'junction;path=a:2,b:_0,terminal:1',
            },
            red: {
              %w[B1] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:4,b:_0;path=a:5,b:_0',
              %w[B11] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70;path=a:0,b:_0;path=a:1,b:_0',
              %w[F1] => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
              %w[F11] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0;path=a:2,b:_0',
            },
            yellow: {
              %w[B5] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:5,b:_1;label=OO',
              %w[F3] => 'city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=OO',
              %w[G8] => 'city=revenue:30;path=a:3,b:_0;label=B',
            },
            white: {
              %w[B3 C4 D1 E2 E4 E10 G6] => '',
              %w[B7 C6 C10 D11] => 'upgrade=cost:40,terrain:river',
              %w[D7] => 'upgrade=cost:40,terrain:mountain',
              %w[G2 G4 F9] => 'city=revenue:0',
              %w[C2 D3 E6] => 'city=revenue:0;upgrade=cost:20,terrain:river',
              %w[C8 D9 E8] => 'city=revenue:0;upgrade=cost:60,terrain:river',
              %w[B9 F5] => 'town=revenue:0;town=revenue:0',
              %w[D5] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',
              %w[F7] => 'town=revenue:0;town=revenue:0;upgrade=cost:80,terrain:river',
            },
          }
        end

        def map_ms_game_companies
          auction_list = [
            {
              name: '1st Player (PD)',
              sym: 'P1',
              value: 0,
              revenue: 0,
              desc: 'Winner takes first position',
              color: 'white',
              text_color: 'black',
            },
            {
              name: '2nd Player',
              sym: 'P2',
              value: 0,
              revenue: 0,
              desc: 'Winner takes second position',
              color: 'white',
              text_color: 'black',
            },
            {
              name: '3rd Player',
              sym: 'P3',
              value: 0,
              revenue: 0,
              desc: 'Winner takes third position',
              color: 'white',
              text_color: 'black',
            },
          ]

          auction_list.take(@players.size - 1)
        end

        # DGN GFN PHX KKN SPX
        def map_ms_game_corporations(corps)
          clist = CORP_DEST.sort_by { rand }.take(5)
          corps.each_with_index do |c, idx|
            c[:coordinates] = clist[idx][:corp_hex]
            c[:city] = clist[idx][:corp_city]
            c[:abilities] = [{ type: 'assign_hexes', hexes: [clist[idx][:dest]], count: 1 }]
            c[:tokens] = [0, 40] # third token is unlocked after destination run
          end
          corps
        end

        def map_ms_game_cash
          { 2 => 860, 3 => 575, 4 => 430 }
        end

        def map_ms_game_cert_limit
          { 2 => 16, 3 => 11, 4 => 8 }
        end

        def map_ms_game_capitalization
          :full
        end

        def map_ms_game_market
          self.class::MARKET_2D
        end

        def map_ms_game_trains(trains)
          find_train(trains, '2')[:num] = 4
          find_train(trains, '3')[:num] = 3
          find_train(trains, '4')[:num] = 3
          find_train(trains, '4')[:rusts_on] = '8'
          find_train(trains, '5')[:num] = 2
          find_train(trains, '5')[:price] = 450
          find_train(trains, '5')[:rusts_on] = 'D'
          find_train(trains, '6')[:num] = 1
          find_train(trains, '8')[:num] = 2
          find_train(trains, 'D')[:num] = 10
          find_train(trains, 'D')[:available_on] = '8'
          find_train(trains, 'D')[:discount] = { '5' => 200, '6' => 200, '8' => 200 }
          trains
        end

        def map_ms_game_phases
          [
            { name: '2', train_limit: 3, tiles: [:yellow], operating_rounds: 1 },
            {
              name: '3',
              on: '3',
              train_limit: 3,
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
              name: '8',
              on: '8',
              train_limit: 2,
              tiles: %i[yellow green brown gray],
              operating_rounds: 2,
            },
            {
              name: 'D',
              on: 'D',
              train_limit: 2,
              tiles: %i[yellow green brown gray],
              operating_rounds: 3,
            },
          ]
        end

        def map_ms_post_game_phases(phases)
          phases
        end

        def map_ms_constants
          redef_const(:GAME_END_CHECK, { bankrupt: :immediate, final_phase: :one_more_full_or_set, bank: :full_or })
        end

        def map_ms_init_bank
          Bank.new(8_000, log: @log, check: true)
        end

        def map_ms_init_round
          @log << '-- Player Order Auction -- '
          Engine::Round::Auction.new(self, [
            GSystem18::Step::OrderAuction,
          ])
        end

        def map_ms_reorder_players
          # call base game method if players have no privates
          return Engine::Game::Base.instance_method(:reorder_players).bind_call(self) unless @players.any? do |p|
                                                                                               !p.companies.empty?
                                                                                             end

          # find positional companies
          plast = @players.find { |p| p.companies.empty? }
          p1 = @players.find { |p| p.companies.find { |c| c.sym == 'P1' } }
          p2 = @players.find { |p| p.companies.find { |c| c.sym == 'P2' } } || plast
          p3 = @players.find { |p| p.companies.find { |c| c.sym == 'P3' } } || plast

          # remove privates from players
          @players.each { |p| p.companies.clear }

          @players = [p1, p2, p3, plast].take(@players.size)
          @log << "New player order: #{@players.map(&:name).join(', ')}"
        end

        def map_ms_operating_steps
          [
            GSystem18::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            GSystem18::Step::Track,
            GSystem18::Step::CheckConnection,
            GSystem18::Step::ConnectionRoute,
            GSystem18::Step::ConnectionDividend,
            GSystem18::Step::Token,
            Engine::Step::Route,
            GSystem18::Step::Dividend,
            Engine::Step::DiscardTrain,
            GSystem18::Step::BuyTrain,
          ]
        end

        def map_ms_setup
          @corporations.each do |corporation|
            # place all home tokens
            place_home_token(corporation)

            # assign destination
            ability = abilities(corporation, :assign_hexes)
            hex = hex_by_id(ability.hexes.first)

            hex.assign!(corporation)
            ability.description = "Destination: #{hex.location_name} (#{hex.name})"
          end
        end

        def map_ms_destinate(corporation)
          @log << "Destination run for #{corporation.name} is completed"
          corporation.tokens << Engine::Token.new(corporation, price: 100)
          corporation.remove_ability(corporation.abilities.first)
          @round.connection_available[corporation].remove_assignment!(corporation)
        end

        def map_ms_check_route_combination(routes)
          return if routes.empty?

          entity = routes.first.train.owner
          return unless @round.connection_available[entity]

          home_city = entity.tokens.first.city
          dest_hex = @round.connection_available[entity]
          return if routes.any? { |r| r.visited_stops.include?(home_city) && r.visited_stops.map(&:hex).include?(dest_hex) }

          raise GameError, 'At least one train must include home token and destination hex'
        end

        def ms_dest_bonus(route, stops)
          entity = route.train.owner
          return 0 unless @round.connection_available[entity]

          home_city = entity.tokens.first.city
          dest_hex = @round.connection_available[entity]
          dest_stop = stops.find { |s| s.hex == dest_hex }

          if route.visited_stops.include?(home_city) && route.visited_stops.map(&:hex).include?(dest_hex)
            return dest_stop.route_revenue(@phase, route.train)
          end

          0
        end

        def map_ms_extra_revenue_for(route, stops)
          ms_dest_bonus(route, stops)
        end

        def map_ms_extra_revenue_str(route)
          extra = ms_dest_bonus(route, route.stops)
          return '' if extra.zero?

          "+ #{format_revenue_currency(extra)} destination bonus"
        end

        def map_ms_game_end_check_values
          return self.class::GAME_END_CHECK unless @phase.name == 'D'

          { bankrupt: :immediate, final_phase: :one_more_full_or_set }
        end

        def map_ms_train_warranted?(train)
          return false unless train.owner == @depot

          %w[2 3 4 5].include?(train.name)
        end
      end
    end
  end
end
