# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module MapBritainCustomization
        BRITAIN_REGION_HEXES = {
          'Scotland' => %w[A6 A8 A10 B3 B5 B7 B9 C4 C6],
          'Wales' => %w[G4 H3 I2 I4 J3],
        }.freeze

        BRITAIN_MINE_HEXES = %w[B7 D9 G10 I4].freeze
        BRITAIN_LONDON_HEX = 'K10'

        BRITAIN_SCOTLAND_BONUS_VAL_HEX = 'A4'
        BRITAIN_WALES_BONUS_VAL_HEX = 'G2'
        BRITAIN_LONDON_BONUS_VAL_HEX = 'L11'
        BRITAIN_MINE_BONUS_VAL_HEX = 'G12'

        # rubocop:disable Layout/LineLength
        def map_britain_game_tiles(tiles)
          tiles['8'] = 6
          tiles['9'] = 6
          tiles['23'] = 2
          tiles['24'] = 2
          tiles['25'] = 2
          tiles['448'] = 3
          tiles.merge!({
                         'X1' =>
            {
              'count' => 3,
              'color' => 'gray',
              'code' => 'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO',
            },
                         'X2' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
                       })
        end
        # rubocop:enable Layout/LineLength

        def map_britain_layout
          :pointy
        end

        def map_britain_game_location_names
          {
            'A4' => 'Scotland Bonus',
            'A6' => 'Glasgow',
            'A8' => 'Edinburgh',
            'B3' => 'N. Ireland',
            'C4' => '(Scotland)',
            'C8' => 'Carlisle',
            'C10' => 'Newcastle',
            'D11' => 'Sunderland & Middlesbrough',
            'E6' => 'Preston',
            'E10' => 'York',
            'F5' => 'Liverpool',
            'F7' => 'Bolton & Manchester',
            'F9' => 'Leeds & Bradford',
            'F11' => 'Hull',
            'G2' => 'Wales Bonus',
            'G6' => 'Crewe & Stoke on Trent',
            'G8' => 'Derby',
            'G12' => 'Mine Bonus',
            'H3' => '(Wales)',
            'H7' => 'Birmingham & Wolverh\'ton',
            'H9' => 'Nottingham',
            'I2' => 'S. Ireland',
            'I8' => 'Coventry',
            'I12' => 'Norwich',
            'J1' => 'Swansea',
            'J3' => 'Cardiff',
            'J5' => 'Bristol',
            'J9' => 'Bedford & Luton',
            'J11' => 'Cambridge & Colchester',
            'J13' => 'Harwich',
            'K2' => 'Plymouth',
            'K8' => 'Reading & Guildford',
            'K10' => 'London',
            'L5' => 'Southampton',
            'L7' => 'Portsmouth',
            'L11' => 'London Port Bonus',
          }
        end

        # rubocop:disable Layout/LineLength
        def map_britain_game_hexes
          {
            gray: {
              %w[a5] => 'junction;path=a:5,b:_0,terminal:1',
              %w[A4] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40',
              %w[C12] => 'path=a:0,b:1',
              %w[G2] => 'offboard=revenue:yellow_10|green_20|brown_20|gray_30',
              %w[G12] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40',
              %w[J1] => 'town=revenue:10;path=a:4,b:_0',
              %w[L11] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40',
            },

            red: {
              %w[B3] => 'offboard=revenue:yellow_20|green_20|brown_30|gray_30;path=a:4,b:_0;path=a:5,b:_0;icon=image:port',
              %w[F5] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_70;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
              %w[I2] => 'offboard=revenue:yellow_20|green_20|brown_30|gray_30;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;icon=image:port',
              %w[J13] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;icon=image:port',
              %w[K2] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:4,b:_0;path=a:5,b:_0;icon=image:port',
              %w[K10] => 'offboard=revenue:yellow_40|green_50|brown_70|gray_100;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
            green: {
              %w[F7] => 'city=revenue:40,pos:0;city=revenue:40,pos:2;path=a:0,b:_0;path=a:2,b:_1;label=OO',
              %w[H7] => 'city=revenue:40,pos:3;city=revenue:40,pos:5;path=a:3,b:_1;path=a:5,b:_0;label=OO',
            },
            yellow: {
              %w[A6] => 'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=B',
              %w[F9] => 'city=revenue:30,pos:0;city=revenue:30,pos:3;path=a:3,b:_1;label=OO',
            },
            white: {
              %w[B5 C4 H11 I10 J7 K6 K12 L3 L9] => '',
              %w[A8] => 'city=revenue:0',
              %w[A10] => 'border=type:province,color:brown,edge:5',
              %w[B7] => 'upgrade=cost:40,terrain:mountain;icon=image:mine,sticky:1;border=type:province,color:brown,edge:5',
              %w[B9] => 'upgrade=cost:40,terrain:mountain;border=type:province,color:brown,edge:0;border=type:province,color:brown,edge:4;border=type:province,color:brown,edge:5',
              %w[B11] => 'border=type:province,color:brown,edge:1;border=type:province,color:brown,edge:2',
              %w[C6] => 'border=type:province,color:brown,cost:80,edge:5',
              %w[C8] => 'city=revenue:0;upgrade=cost:20,terrain:water;border=type:province,color:brown,edge:1;border=type:province,color:brown,edge:2;border=type:province,color:brown,edge:3',
              %w[C10] => 'city=revenue:0;upgrade=cost:20,terrain:water;border=type:province,color:brown,edge:2',
              %w[D7] => 'upgrade=cost:40,terrain:mountain;border=type:province,color:brown,cost:80,edge:2',
              %w[D9] => 'upgrade=cost:40,terrain:mountain;icon=image:mine,sticky:1',
              %w[D11] => 'town=revenue:0;town=revenue:0',
              %w[E6 E10] => 'city=revenue:0',
              %w[E8] => 'upgrade=cost:80,terrain:mountain',
              %w[E12] => 'upgrade=cost:40,terrain:mountain',
              %w[F11] => 'city=revenue:0;upgrade=cost:20,terrain:water',
              %w[G4] => 'upgrade=cost:40,terrain:mountain;border=type:province,color:brown,edge:4;border=type:province,color:brown,edge:5',
              %w[G6] => 'town=revenue:0;town=revenue:0;border=type:province,color:brown,edge:1',
              %w[G8] => 'city=revenue:0',
              %w[G10] => 'upgrade=cost:20,terrain:water;icon=image:mine,sticky:1',
              %w[H3] => 'upgrade=cost:40,terrain:mountain;border=type:province,color:brown,edge:4',
              %w[H5] => 'border=type:province,color:brown,edge:0;border=type:province,color:brown,edge:1;border=type:province,color:brown,edge:2',
              %w[H9] => 'city=revenue:0',
              %w[I4] => 'upgrade=cost:40,terrain:mountain;icon=image:mine,sticky:1;border=type:province,color:brown,edge:3;border=type:province,color:brown,edge:4;border=type:province,color:brown,edge:5',
              %w[I6] => 'upgrade=cost:20,terrain:water;border=type:province,color:brown,edge:1',
              %w[I8 I12] => 'city=revenue:0',
              %w[J3] => 'city=revenue:0;border=type:province,color:brown,cost:80,edge:4;border=type:impassable,edge:5',
              %w[J5] => 'city=revenue:0;border=type:province,color:brown,cost:80,edge:1;border=type:province,color:brown,edge:2',
              %w[J9 J11] => 'town=revenue:0;town=revenue:0',
              %w[K4] => 'border=type:impassable,edge:2',
              %w[K8] => 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:water',
              %w[L5 L7] => 'city=revenue:0',
            },
          }
        end
        # rubocop:enable Layout/LineLength

        def map_britain_game_companies
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
            {
              name: 'PGS Charter',
              sym: 'PGS',
              value: 0,
              revenue: 0,
              desc: 'Allows opening PGS corporation',
              color: '#cd79a7',
              text_color: 'black',
            },
          ]
        end

        # DGN GFN PHX KKN SPX PGS
        def map_britain_game_corporations(corps)
          corps.append(
            {
              float_percent: 20,
              sym: 'PGS',
              name: 'Pegasus',
              logo: 'System18/PGS',
              tokens: [0, 40, 100],
              coordinates: nil,
              color: '#cd79a7',
              reservation_color: nil,
              max_ownership_percent: 60,
            }
          )
          corps.each_with_index do |c, idx|
            c[:float_percent] = 20
            c[:always_market_price] = true
            c[:tokens] = [[0, 0,  100, 100],      # DGN
                          [0, 40, 100, 100],      # GFN
                          [0, 0,  100, 100],      # PHX
                          [0, 40, 100, 100],      # KKN
                          [0, 40, 100, 100],      # SPX
                          [0, 40, 100, 100]][idx] # PGS
            c[:coordinates] = [%w[F7 I8], 'J5', %w[F9 G8], 'A6', 'I12', 'A8'][idx]
            c[:city] = [1, nil, 1, nil, nil, nil][idx]
          end
          corps
        end

        def map_britain_game_cash
          { 3 => 420, 4 => 315, 5 => 250 }
        end

        def map_britain_game_cert_limit
          { 3 => 16, 4 => 12, 5 => 10 }
        end

        def map_britain_game_capitalization
          :incremental
        end

        def map_britain_game_market
          self.class::MARKET_1D
        end

        def map_britain_game_trains(trains)
          # don't use D trains
          trains.delete(find_train(trains, 'D'))
          find_train(trains, '4')[:rusts_on] = '8'
          # udpate quantities
          find_train(trains, '2')[:num] = 6
          find_train(trains, '3')[:num] = 4
          find_train(trains, '4')[:num] = 3
          find_train(trains, '5')[:num] = 3
          find_train(trains, '6')[:num] = 2
          find_train(trains, '8')[:num] = 99
          trains.append({
                          name: '4D',
                          distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 99, 'multiplier' => 2 }],
                          price: 1000,
                          num: 99,
                          available_on: '8',
                        })
          trains
        end

        def map_britain_game_phases
          self.class::S18_INCCAP_PHASES
        end

        def map_britain_post_game_phases(phases)
          phases
        end

        def map_britain_constants
          redef_const(:CURRENCY_FORMAT_STR, '£%s')
          redef_const(:TILE_UPGRADES_MUST_USE_MAX_EXITS, %i[unlabeled_cities])
          redef_const(:TILE_LAYS, [{ lay: true, upgrade: true, cost: 0 }, { lay_replaced: :if_green_upgraded }])
        end

        def map_britain_setup
          @britain_mines = BRITAIN_MINE_HEXES.map { |h| hex_by_id(h) }
          @britain_corps_with_mines = {}
          @scotland_bonus_val = hex_by_id(BRITAIN_SCOTLAND_BONUS_VAL_HEX).tile.offboards.first
          @wales_bonus_val = hex_by_id(BRITAIN_WALES_BONUS_VAL_HEX).tile.offboards.first
          @london_bonus_val = hex_by_id(BRITAIN_LONDON_BONUS_VAL_HEX).tile.offboards.first
          @mine_bonus_val = hex_by_id(BRITAIN_MINE_BONUS_VAL_HEX).tile.offboards.first
        end

        def map_britain_company_header(_company)
          'CHARTER'
        end

        def map_britain_init_round
          map_britain_new_parliament_round
        end

        def map_britain_new_parliament_round
          @log << "-- Parliament Round #{@turn} -- "
          GSystem18::Round::Parliament.new(self, [
            GSystem18::Step::CharterAuction,
          ])
        end

        def map_britain_next_round!
          @round =
            case @round
            when Engine::Round::Stock
              map_britain_stock_round_finished
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
                map_britain_new_parliament_round
              end
            else # Parliament Round
              init_round_finished
              new_stock_round
            end
        end

        # remove un-excersized charters from players
        def map_britain_stock_round_finished
          @players.each do |player|
            player.companies.dup.each do |c|
              @log << "Right to open #{c.sym} lapses for #{player.name}"
              player.companies.delete(c)
              c.owner = nil
            end
          end
        end

        def map_britain_can_par?(corporation, entity)
          !corporation.ipoed && entity.companies.find { |c| c.sym == corporation.name }
        end

        def map_britain_after_par(corporation)
          entity = corporation.owner

          company = entity.companies.find { |c| c.sym == corporation.name }
          raise GameError, 'Logic error, no matching company found' unless company

          entity.companies.delete(company)
          company.close!
        end

        # can the corporation reach an icon?
        def map_britain_can_remove_icon?(entity)
          return false unless entity.corporation?
          return false if @britain_corps_with_mines[entity.name]

          @britain_mines.any? { |m| @graph.reachable_hexes(entity).include?(m) }
        end

        def map_britain_icon_hexes(entity)
          return [] unless entity.corporation?
          return [] if @britain_corps_with_mines[entity.name]

          @britain_mines.select { |m| @graph.reachable_hexes(entity).include?(m) }.map(&:id)
        end

        def map_britain_remove_icon(entity, hex_id)
          return unless entity.corporation?
          return if @britain_corps_with_mines[entity.name]

          hex = hex_by_id(hex_id)
          hex.tile.icons.clear # should be the only icon on the tile
          @log << "#{entity.name} takes mine token from #{hex_id}"
          @britain_corps_with_mines[entity.name] = hex_id
        end

        def map_britain_removable_icon_action_str
          'Take a mine token'
        end

        def map_britain_extra_revenue_for(route, stops)
          map_britain_bonuses(route, stops)[:revenue]
        end

        def map_britain_extra_revenue_str(route)
          bonus = map_britain_bonuses(route, route.stops)[:description]
          bonus ? " + #{bonus}" : ''
        end

        def map_britain_bonuses(route, stops)
          train = route.train
          bonus = { revenue: 0 }
          return bonus unless train

          desc = []

          # Scotland (doubles with 4D)
          scotland_city = stops.find do |stop|
            BRITAIN_REGION_HEXES['Scotland'].include?(stop.hex.id) && (stop.city? || stop.offboard?)
          end
          non_scotland_city = stops.find { |stop| !BRITAIN_REGION_HEXES['Scotland'].include?(stop.hex.id) && stop.city? }
          if scotland_city && non_scotland_city
            bonus[:revenue] += @scotland_bonus_val.route_revenue(@phase, train)
            desc << 'Scotland'
          end

          # Wales (doubles with 4D)
          wales_city = stops.find { |stop| BRITAIN_REGION_HEXES['Wales'].include?(stop.hex.id) && (stop.city? || stop.offboard?) }
          non_wales_city = stops.find { |stop| !BRITAIN_REGION_HEXES['Wales'].include?(stop.hex.id) && stop.city? }
          if wales_city && non_wales_city
            bonus[:revenue] += @wales_bonus_val.route_revenue(@phase, train)
            desc << 'Wales'
          end

          # London-Port (doubles with 4D)
          london = stops.find { |stop| stop.hex.id == BRITAIN_LONDON_HEX }
          port = stops.find { |stop| stop.tile.icons.any? { |i| i.name == 'port' } }
          if london && port
            bonus[:revenue] += @london_bonus_val.route_revenue(@phase, train)
            desc << 'London-Port'
          end

          bonus[:description] = "(#{desc.join(', ')})" unless desc.empty?
          bonus
        end

        def map_britain_mine_bonus(routes)
          valid_route = routes.find { |r| !r.stops.empty? }
          train = valid_route&.train
          if train && @britain_corps_with_mines[train.owner.name]
            rev = @mine_bonus_val.route_revenue(@phase, train)
            # undo automatic doubling of revenue with a diesel
            rev /= 2 if train.name == '4D'
            rev
          else
            0
          end
        end

        def map_britain_extra_revenue(_entity, routes)
          map_britain_mine_bonus(routes)
        end

        def map_britain_submit_revenue_str(routes, _show_subsidy)
          train_revenue = routes_revenue(routes)
          mine_revenue = map_britain_mine_bonus(routes)
          return format_revenue_currency(train_revenue) if mine_revenue.zero?

          "#{format_revenue_currency(train_revenue)} + #{format_revenue_currency(mine_revenue)} mine bonus"
        end

        def map_britain_status_str(corporation)
          return unless @britain_corps_with_mines[corporation.name]

          "Mine (from #{@britain_corps_with_mines[corporation.name]})"
        end

        def map_britain_modify_tile_lay(_entity, action)
          return unless action

          if action[:lay_replaced] && @round.upgraded_track &&
              (@round.laid_hexes.first.tile.color == :green)
            action[:lay_replaced] = true
            action[:lay] = true
          else
            action[:lay_replaced] = nil
          end

          action
        end

        def map_britain_pre_lay_tile_action(action, _entity, tile_lay)
          tile = action.tile
          hex = action.hex
          old_tile = hex.tile

          if tile_lay[:lay_replaced] && ((@round.last_old_tile != tile) ||
                                         (@tiles.count { |t| t.name == tile.name } != 1) ||
                                         (tile.color != :yellow))
            raise GameError, 'Must lay yellow tile just replaced'
          end

          @round.last_old_tile = old_tile
        end

        def map_britain_place_home_token(corporation)
          return if corporation.tokens.first&.used

          Array(corporation.coordinates).each do |coord|
            hex = hex_by_id(coord)
            tile = hex&.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
            token = corporation.find_token_by_type

            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token)
          end
        end

        # FIXME: add reopen! method to Engine::Company
        #
        # open company associated with closed corporation
        # def map_britain_close_corporation_extra(corporation)
        #  company = companies.find { |c| c.sym == corporation.name }
        #  company.reopen!
        # end
      end
    end
  end
end
