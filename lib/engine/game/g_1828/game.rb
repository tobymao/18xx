# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'stock_market'
require_relative 'system'
require_relative 'shell'
require_relative 'entities'
require_relative 'map'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G1828
      class Game < Game::Base
        include_meta(G1828::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include Entities
        include Map

        register_colors(hanBlue: '#446CCF',
                        steelBlue: '#4682B4',
                        brick: '#9C661F',
                        powderBlue: '#B0E0E6',
                        khaki: '#F0E68C',
                        darkGoldenrod: '#B8860B',
                        yellowGreen: '#9ACD32',
                        gray70: '#B3B3B3',
                        khakiDark: '#BDB76B',
                        thistle: '#D8BFD8',
                        lightCoral: '#F08080',
                        tan: '#D2B48C',
                        gray50: '#7F7F7F',
                        cinnabarGreen: '#61B329',
                        tomato: '#FF6347',
                        plum: '#DDA0DD',
                        lightGoldenrod: '#EEDD82')

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 99, 4 => 99, 5 => 99 }.freeze

        STARTING_CASH = { 3 => 800, 4 => 700, 5 => 620 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[122
             130
             138
             147
             157
             167
             178
             191
             213
             240
             272
             312
             357
             412
             500e],
          %w[112
             120w
             127
             136
             145
             154
             164
             176
             197
             221
             251
             287
             329
             380
             443],
          %w[102
             107
             113
             119
             126
             133
             140
             149
             165
             184
             207
             235
             267
             305
             353],
          %w[95
             100
             105z
             111
             117
             124
             130
             139
             153
             171
             192
             218
             248
             284
             328],
          %w[87
             92
             96
             101
             106
             111
             117
             124
             136
             151
             169
             191
             216
             246
             283],
          %w[81
             86
             90
             94x
             99
             104
             109
             116
             127
             141
             158
             179
             202
             230],
          %w[76
             80
             84
             88
             93
             97
             102
             108
             119
             132
             148
             167
             189],
          %w[71o
             75
             78
             82
             86x
             91
             95
             101
             111
             123
             138
             156],
          %w[66o 70o 73 77 81 85 89 94 104 115 129],
          %w[62o 65o 69 72 76 79p 83 88 97 108],
          %w[58o 61o 64o 67 71 74 78 82 91 101],
          %w[54o 57o 60o 63o 66 69 71p 77 85],
          %w[51o 53o 56o 59o 62 65 68 72 79],
          %w[47o 50o 52o 55o 58o 60 64 67p 74],
          ['', '47o', '49o', '51o', '54o', '57o', '59'],
          ['', '43o', '46o', '48o', '50o', '53o', '55o'],
          ['', '', '43o', '45o', '47o', '49o', '52o'],
          ['', '', '40o', '42o', '44o', '46o', '48o'],
        ].freeze

        PHASES = [{ name: 'Yellow', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: 'Green',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Blue',
                    on: '5',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Brown',
                    on: '3+D',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: 'Red',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'Gray',
                    on: '8E',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'Purple',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 4,
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '5', num: 7 },
                  {
                    name: '3',
                    distance: 3,
                    price: 160,
                    rusts_on: '6',
                    num: 9,
                    events: [{ 'type' => 'green_par' }],
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 250,
                    rusts_on: '8E',
                    num: 4,
                    events: [{ 'type' => 'blue_par' }],
                  },
                  {
                    name: '3+D',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                               {
                                 'nodes' => ['town'],
                                 'pay' => 99,
                                 'visit' => 99,
                                 'multiplier' => 2,
                               }],
                    price: 350,
                    rusts_on: 'D',
                    num: 6,
                    events: [{ 'type' => 'brown_par' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 650,
                    num: 4,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: '8E',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                               { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                    price: 800,
                    num: 3,
                  },
                  {
                    name: 'D',
                    distance: 999,
                    price: 900,
                    num: 20,
                    events: [{ 'type' => 'remove_corporations' }],
                  }].freeze

        MULTIPLE_BUY_TYPES = %i[unlimited].freeze

        MUST_BID_INCREMENT_MULTIPLE = true
        MIN_BID_INCREMENT = 5

        HOME_TOKEN_TIMING = :operate

        TILE_RESERVATION_BLOCKS_OTHERS = :always

        GAME_END_CHECK = {
          bankrupt: :immediate,
          stock_market: :current_round,
          final_phase: :one_more_full_or_set,
        }.freeze

        SELL_BUY_ORDER = :sell_buy_sell

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        TRACK_RESTRICTION = :permissive

        DISCARDED_TRAINS = :remove

        MARKET_SHARE_LIMIT = 80 # percent

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Yellow Phase Par',
                                              par_1: 'Green Phase Par',
                                              par_2: 'Blue Phase Par',
                                              par_3: 'Brown Phase Par',
                                              unlimited: 'Corporation shares can be held above 60% and ' \
                                                         'President may buy two shares at a time')

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :yellow,
                                                            par_1: :green,
                                                            par_2: :blue,
                                                            par_3: :brown,
                                                            unlimited: :gray,
                                                            endgame: :red)

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'green_par' => ['Green phase pars',
                          '$86 and $94 par prices are now available'],
          'blue_par' => ['Blue phase pars',
                         '$105 par price is now available'],
          'brown_par' => ['Brown phase pars',
                          '$120 par price is now available'],
          'remove_corporations' => ['Unparred corporations removed',
                                    'All unparred corporations are removed at the beginning of next stock round.' \
                                    ' Blocking tokens placed in home stations.']
        ).freeze

        VA_COALFIELDS_HEX = 'K11'
        VA_TUNNEL_HEX = 'K13'
        COAL_MARKER_ICON = 'coal'
        COAL_MARKER_COST = 120

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1828::Step::CompanyPendingPar,
            G1828::Step::WaterfallAuction,
          ])
        end

        def stock_round
          G1828::Round::Stock.new(self, [
            G1828::Step::DiscardTrain,
            G1828::Step::RemoveTokens,
            G1828::Step::Merger,
            G1828::Step::Exchange,
            G1828::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G1828::Step::Exchange,
            G1828::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1828::Step::BuyCompany,
            G1828::Step::SpecialTrack,
            G1828::Step::SpecialToken,
            G1828::Step::SpecialBuy,
            G1828::Step::Track,
            G1828::Step::Token,
            G1828::Step::Route,
            G1828::Step::Dividend,
            G1828::Step::SwapTrain,
            G1828::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def setup
          setup_minors
          setup_company_min_price

          @available_par_groups = %i[par]

          @log << "-- Setting game up for #{@players.size} players --"
          remove_extra_private_companies
          remove_extra_trains

          @coal_marker_ability =
            Engine::Ability::Description.new(type: 'description', description: 'Coal Marker')
          block_va_coalfields

          @blocking_corporation = Corporation.new(sym: 'B', name: 'Blocking', logo: '1828/blocking', tokens: [0])
        end

        def init_stock_market
          G1828::StockMarket.new(self.class::MARKET, [],
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def init_tiles
          tiles = super

          tiles.find { |tile| tile.name == '53' }.label = 'Ba'
          tiles.find { |tile| tile.name == '61' }.label = 'Ba'
          tiles.find { |tile| tile.name == '121' }.label = 'Bo'
          tiles.find { |tile| tile.name == '997' }.label = 'Bo'

          tiles
        end

        TILE_LAYS = [{ lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true, cost: 0 }].freeze
        EXTRA_TILE_LAY_CORPS = %w[B&M NYH].freeze

        def tile_lays(entity)
          tile_lays = super
          tile_lays += [{ lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true }] if entity.system?
          (entity.system? ? entity.corporations.map(&:name) : [entity.name]).each do |corp_name|
            next unless EXTRA_TILE_LAY_CORPS.include?(corp_name)

            tile_lays += [
              {
                lay: :not_if_upgraded,
                upgrade: false,
                cannot_reuse_same_hex: true,
                cost: 40,
              },
            ]
          end

          tile_lays
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def show_game_cert_limit?
          false
        end

        def init_round_finished
          @players.rotate!(@round.entity_index)

          @companies.each do |company|
            next unless company.owner

            abilities(company, :revenue_change, time: 'auction_end') do |ability|
              company.revenue = ability.revenue
            end
          end
        end

        def event_green_par!
          @log << "-- Event: #{EVENTS_TEXT['green_par'][1]} --"
          @available_par_groups << :par_1
          update_cache(:share_prices)
        end

        def event_blue_par!
          @log << "-- Event: #{EVENTS_TEXT['blue_par'][1]} --"
          @available_par_groups << :par_2
          update_cache(:share_prices)
        end

        def event_brown_par!
          @log << "-- Event: #{EVENTS_TEXT['brown_par'][1]} --"
          @available_par_groups << :par_3
          update_cache(:share_prices)
        end

        def event_close_companies!
          super

          @minors.dup.each { |minor| remove_minor!(minor, block: true) }
        end

        def event_remove_corporations!
          @log << "-- Event: #{EVENTS_TEXT['remove_corporations'][1]}. --"
          @log << 'Unparred corporations will be removed at the beginning of the next stock round'
        end

        def new_stock_round
          new_sr = super
          remove_unparred_corporations! if @phase.current[:name] == 'Purple'
          new_sr
        end

        def remove_unparred_corporations!
          @corporations.reject(&:ipoed).reject(&:closed?).each do |corporation|
            place_home_blocking_token(corporation)
            @log << "Removing #{corporation.name}"
            @corporations.delete(corporation)
          end
        end

        def remove_minor!(minor, block: false)
          minor.spend(minor.cash, @bank) if minor.cash.positive?
          minor.tokens.each do |token|
            city = token&.city
            token.remove!
            place_blocking_token(city.hex, city: city) if block && city
          end
          @graph.clear_graph_for(minor)
          @minors.delete(minor)

          @round.force_next_entity! if @round.current_entity == minor
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Virginia tunnel can only be upgraded to #4 tile
          return false if from.hex.id == VA_TUNNEL_HEX && to.name != '4'

          super
        end

        def par_prices
          @stock_market.share_prices_with_types(@available_par_groups)
        end

        def merge_candidates(player, corporation)
          return [] if corporation.system?

          @corporations.select { |candidate| merge_candidate?(player, corporation, candidate) }
        end

        def merge_candidate?(player, corporation, candidate)
          return false if candidate == corporation ||
                          candidate.system? ||
                          !candidate.ipoed ||
                          (corporation.owner != player && candidate.owner != player) ||
                          candidate.operated? != corporation.operated? ||
                          (!candidate.floated? && !corporation.floated?)

          # account for another player having 5+ shares
          @players.any? do |p|
            num_shares = p.num_shares_of(candidate) + p.num_shares_of(corporation)
            num_shares >= 6 ||
              (num_shares == 5 && !sold_this_round?(p, candidate) && !sold_this_round?(p, corporation))
          end
        end

        def sold_this_round?(entity, corporation)
          return false unless @round.players_sold

          @round.players_sold[entity][corporation]
        end

        def create_system(corporations)
          return nil unless corporations.size == 2

          system_data = CORPORATIONS.find { |c| c[:sym] == corporations.first.id }.dup
          system_data[:sym] = corporations.map(&:name).join('-')
          system_data[:tokens] = []
          system_data[:abilities] = []
          system_data[:corporations] = corporations
          system = init_system(@stock_market, system_data)

          @corporations << system
          @_corporations[system.id] = system
          system.shares.each { |share| @_shares[share.id] = share }

          corporations.each { |corporation| transfer_assets_to_system(corporation, system) }

          # Order tokens for better visual
          max_price = system.tokens.max_by(&:price).price + 1
          system.tokens.sort_by! { |t| (t.used ? -max_price : max_price) + t.price }

          place_system_blocking_tokens(system)

          # Make sure the system will not own two coal markers
          if coal_markers(system).size > 1
            remove_coal_marker(system)
            add_coal_marker_to_va_coalfields
            @log << "#{system.name} cannot have two coal markers, returning one to Virginia Coalfields"
          end

          @stock_market.set_par(system, system_market_price(corporations))
          system.ipoed = true

          system
        end

        def transfer_assets_to_system(corporation, system)
          corporation.spend(corporation.cash, system) if corporation.cash.positive?

          # Transfer tokens
          used, unused = corporation.tokens.partition(&:used)
          used.each do |t|
            new_token = Engine::Token.new(system, price: t.price)
            system.tokens << new_token
            t.swap!(new_token, check_tokenable: false)
          end
          unused.sort_by(&:price).each { |t| system.tokens << Engine::Token.new(system, price: t.price) }
          corporation.tokens.clear

          # Transfer companies
          corporation.companies.each do |company|
            company.owner = system
            system.companies << company
          end
          corporation.companies.clear

          # Transfer abilities
          corporation.all_abilities.dup.each do |ability|
            corporation.remove_ability(ability)
            system.add_ability(ability)
          end

          # Create shell and transfer
          shell = G1828::Shell.new(corporation.name, system)
          system.shells << shell
          corporation.trains.dup.each do |train|
            buy_train(system, train, :free)
            shell.trains << train
          end
        end

        def ipo_reserved_name(_entity = nil)
          'Treasury'
        end

        def coal_marker_available?
          hex_by_id(VA_COALFIELDS_HEX).tile.icons.any? { |icon| icon.name == COAL_MARKER_ICON }
        end

        def coal_marker?(entity)
          return false unless entity.corporation?

          coal_markers(entity).any?
        end

        def coal_markers(entity)
          entity.all_abilities.select { |ability| ability.description == @coal_marker_ability.description }
        end

        def connected_to_coalfields?(entity)
          graph.reachable_hexes(entity).include?(hex_by_id(VA_COALFIELDS_HEX))
        end

        def can_buy_coal_marker?(entity)
          return false unless entity.corporation?

          coal_marker_available? &&
            !coal_marker?(entity) &&
            buying_power(entity) >= COAL_MARKER_COST &&
            connected_to_coalfields?(entity)
        end

        def buy_coal_marker(entity)
          return unless can_buy_coal_marker?(entity)

          entity.spend(COAL_MARKER_COST, @bank)
          entity.add_ability(@coal_marker_ability.dup)
          @log << "#{entity.name} buys a coal marker for $#{COAL_MARKER_COST}"

          tile_icons = hex_by_id(VA_COALFIELDS_HEX).tile.icons
          tile_icons.delete_at(tile_icons.find_index { |icon| icon.name == COAL_MARKER_ICON })

          graph.clear
        end

        def acquire_va_tunnel_coal_marker(entity)
          entity = entity.owner if entity.company?

          @log << "#{entity.name} acquires a coal marker"
          if coal_marker?(entity)
            @log << "#{entity.name} already owns a coal marker, placing coal marker on Virginia Coalfields"
            add_coal_marker_to_va_coalfields
          else
            entity.add_ability(@coal_marker_ability.dup)
          end
        end

        def remove_coal_marker(entity)
          coal = entity.all_abilities.find { |ability| ability.description == @coal_marker_ability.description }
          entity.remove_ability(coal)
        end

        def add_coal_marker_to_va_coalfields
          hex_by_id(VA_COALFIELDS_HEX).tile.icons << Engine::Part::Icon.new('1828/coal', 'coal')
        end

        def block_va_coalfields
          coalfields = hex_by_id(VA_COALFIELDS_HEX).tile.cities.first

          coalfields.instance_variable_set(:@game, self)

          def coalfields.blocks?(corporation)
            !@game.coal_marker?(corporation)
          end
        end

        def can_run_route?(entity)
          return false if entity.id == 'C&P' && @round.laid_hexes.empty?

          super
        end

        def check_route_token(route, token)
          return true if route.corporation.id == 'C&P'

          super
        end

        def city_tokened_by?(city, entity)
          return true if entity.id == 'C&P' && @round.current_operator == entity && @round.laid_hexes.include?(city.hex)

          super
        end

        def place_home_token(corporation)
          if corporation.system? && !corporation.tokens.first&.used
            corporation.corporations.each do |c|
              token = Engine::Token.new(c)
              c.tokens << token
              place_home_token(c)

              system_token = corporation.tokens.find do |t|
                t.price.zero? && !t.used && !@round.pending_tokens.find { |p_t| p_t[:token] == t }
              end
              if (pending_token = @round.pending_tokens.find { |p_t| p_t[:entity] == c })
                pending_token[:entity] = corporation
                pending_token[:token] = system_token
                pending_token[:hexes].first.tile.reservations.map! { |r| r == c ? corporation : r }
              else
                token.swap!(system_token, check_tokenable: false)
              end
            end
          else
            super
          end
        end

        def place_blocking_token(hex, city: nil)
          @log << "Placing a blocking token on #{hex.name} (#{hex.location_name})"
          token = Token.new(@blocking_corporation)
          city ||= hex.tile.cities[0]
          city.place_token(@blocking_corporation, token, check_tokenable: false)
        end

        def blocking_token?(token)
          token&.corporation == @blocking_corporation
        end

        def exchange_for_partial_presidency?
          true
        end

        def exchange_partial_percent(share)
          return nil unless share.president

          100 / share.num_shares
        end

        def system_by_id(id)
          corporation_by_id(id)
        end

        def close_companies_on_event!(entity, event)
          return unless event == 'bought_train'

          if entity.system?
            entity.corporations.each { |c| super(c, event) }
          else
            super
          end
        end

        def remove_train(train)
          super

          train.owner.remove_train(train) if train.owner&.system?
        end

        def hex_blocked_by_ability?(entity, _ability, hex, _tile = nil)
          return false if entity.name == 'C&P' && hex.id == 'C15'

          super
        end

        def purchasable_companies(entity = nil)
          return [] if entity&.minor?

          super
        end

        private

        def setup_minors
          @minors.each do |minor|
            train = @depot.upcoming[1]
            train.buyable = false
            train.rusts_on = nil
            buy_train(minor, train, :free)
            @depot.forget_train(train)
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[0].place_token(minor, minor.next_token, free: true)
          end
        end

        def setup_company_min_price
          @companies.each { |company| company.min_price = 1 }
        end

        def privates_to_remove
          ok = false
          until ok
            to_remove = companies.find_all { |company| company.value == 250 }
                                 .sort_by { rand }
                                 .take(7 - @players.size)
            if @optional_rules&.include?(:ensure_good_privates)
              removed_syms = to_remove.map(&:sym)
              ok = !%w[GT NW OSH].all? { |sym| removed_syms.include?(sym) }
            else
              ok = true
            end
          end
          to_remove
        end

        def remove_extra_private_companies
          to_remove = privates_to_remove
          to_remove.each do |company|
            company.close!
            @round.steps.find { |step| step.is_a?(G1828::Step::WaterfallAuction) }.companies.delete(company)
            @log << "Removing #{company.name}"
          end
        end

        def remove_extra_trains
          return unless @players.size < 5

          to_remove = @depot.trains.reverse.find { |train| train.name == '6' }
          @depot.forget_train(to_remove)
          @log << "Removing #{to_remove.name} train"
        end

        def place_home_blocking_token(corporation)
          cities = []

          hex = hex_by_id(corporation.coordinates)
          if hex.tile.reserved_by?(corporation)
            cities.concat(hex.tile.cities)
          else
            cities << hex.tile.cities.find { |city| city.reserved_by?(corporation) }
            cities.first.remove_reservation!(corporation)
          end

          cities.each { |city| place_blocking_token(hex, city: city) }
        end

        def init_system(stock_market, system)
          G1828::System.new(
            min_price: stock_market.par_prices.map(&:price).min,
            capitalization: self.class::CAPITALIZATION,
            **system.merge(corporation_opts),
          )
        end

        def place_system_blocking_tokens(system)
          system.tokens.select(&:used).group_by(&:city).each do |city, tokens|
            next unless tokens.size > 1

            tokens[1].remove!
            place_blocking_token(city.hex, city: city)
          end
        end

        def system_market_price(corporations)
          market = @stock_market.market
          share_prices = corporations.map(&:share_price)
          share_values = share_prices.map(&:price).sort

          left_most_col = share_prices.min { |a, b| a.coordinates[1] <=> b.coordinates[1] }.coordinates[1]
          max_share_value = share_values[1] + (share_values[0] / 2).floor

          new_market_price = nil
          if market[0][left_most_col].price < max_share_value
            i = market[0].size - 1
            i -= 1 while market[0][i].price > max_share_value
            new_market_price = market[0][i]
          else
            i = 0
            i += 1 while market[i][left_most_col].price > max_share_value
            new_market_price = market[i][left_most_col]
          end

          new_market_price
        end

        def check_connected(route, corporation)
          if route_includes_coalfields?(route) && !coal_marker?(corporation)
            raise GameError, 'route to Virginia Coalfields requires Coal Marker'
          end

          raise GameError, 'route must include laid tile' if corporation.id == 'C&P' && !route_uses_tile_lay(route)

          super
        end

        def route_includes_coalfields?(route)
          route.connection_hexes.flatten.include?(self.class::VA_COALFIELDS_HEX)
        end

        def route_uses_tile_lay(route)
          stops = route.visited_stops
          tile = @round.laid_hexes.first&.tile

          return !(stops & tile.nodes).empty? unless tile.nodes.empty?

          tile.paths.each do |path|
            path.walk { |p| return true unless (stops & p.nodes).empty? }
          end

          false
        end
      end
    end
  end
end
