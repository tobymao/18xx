# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'
require_relative '../cities_plus_towns_route_distance_str'
require_relative '../double_sided_tiles'

module Engine
  module Game
    module G18ESP
      class Game < Game::Base
        include_meta(G18ESP::Meta)
        include Entities
        include Map
        include CitiesPlusTownsRouteDistanceStr
        include DoubleSidedTiles

        attr_reader :can_acquire_minors

        attr_accessor :combined_trains, :luxury_carriages

        CURRENCY_FORMAT_STR = '₧%d'

        BANK_CASH = 99_999

        IMPASSABLE_HEX_COLORS = %i[gray red blue orange].freeze

        CERT_LIMIT = { 3 => 27, 4 => 20, 5 => 16, 6 => 13 }.freeze

        STARTING_CASH = { 3 => 860, 4 => 650, 5 => 520, 6 => 440 }.freeze

        NORTH_CORPS = %w[FdSB FdLR CFEA CFLG SFVA FdC].freeze

        TRACK_RESTRICTION = :permissive

        TILE_RESERVATION_BLOCKS_OTHERS = :single_slot_cities

        MOUNTAIN_PASS_TOKEN_HEXES = %w[L8 J10 H12 D12].freeze

        MOUNTAIN_PASS_TOKEN_COST = { 'L8' => 80, 'J10' => 80, 'H12' => 60, 'D12' => 100 }.freeze

        MOUNTAIN_PASS_TOKEN_BONUS = { 'L8' => 40, 'J10' => 40, 'H12' => 30, 'D12' => 50 }.freeze

        MINE_CLOSE_COST = 30

        CARRIAGE_COST = 80

        COMBINED_BONUS = 200

        BONUS = 100

        MINOR_TAKEOVER_COST = 100

        MOUNTAIN_SECOND_TOKEN_COST = 50

        SELL_AFTER = :operate

        SELL_BUY_ORDER = :sell_buy

        NORTH_SOUTH_DIVIDE = 13

        P2_TRAIN_ID = '2-0'

        P3_TRAIN_ID = '2P-0'

        ARANJUEZ_HEX = 'F26'

        MADRID_HEX = 'F24'

        P4_HEX = 'H12'

        DOUBLE_HEX = %w[D6 C31 J20].freeze

        P4_DISCOUNT = 40

        BASE_MINE_BONUS = { yellow: 30, green: 20, brown: 10, gray: 0 }.freeze

        ALLOW_REMOVING_TOWNS = true

        DISCARDED_TRAINS = :remove

        BANKRUPTCY_ALLOWED = false

        EBUY_PRES_SWAP = false

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        EBUY_CAN_TAKE_PLAYER_LOAN = :no_sell

        GAME_END_CHECK = { second_eight: :one_more_full_or_set }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          second_eight: 'Second 8 train is bought'
        )

        MINOR_TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze
        MAJOR_TILE_LAYS = [
          { lay: true, upgrade: true, cost: 0 },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        MARKET = [
          %w[50 55 60 65 70p 75p 80p 85p 90p 95p 100p 105 110 115 120
             126 132 138 144 151 158 165 172 180 188 196 204 213 222 231 240 250 260
             270 280 295 310 325 340 360 380 400],
        ].freeze

        PHASES = [{
          name: '2',
          train_limit: { minor: 2, major: 4 },
          tiles: %i[yellow],
          operating_rounds: 1,
          status: %w[can_buy_companies],
        },
                  {
                    name: '3',
                    on: '3',
                    train_limit: { minor: 2, major: 4 },
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies can_buy_trains mountain_pass lay_second_tile higher_par_prices],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: { minor: 1, major: 3 },
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies can_buy_trains mountain_pass lay_second_tile higher_par_prices],
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: { minor: 1, major: 3 },
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: %w[can_buy_trains mountain_pass lay_second_tile higher_par_prices],
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: { minor: 1, major: 2 },
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: %w[can_buy_trains mountain_pass lay_second_tile higher_par_prices],
                  },
                  {
                    name: '8',
                    on: '8',
                    train_limit: { minor: 1, major: 2 },
                    tiles: %i[yellow green brown gray],
                    operating_rounds: 3,
                    status: %w[can_buy_trains mountain_pass lay_second_tile higher_par_prices],
                  }].freeze

        TRAINS = [

          {
            name: '2P',
            distance: 2,
            price: 0,
            num: 1,
          },

          {
            name: '2',
            distance: 2,
            price: 100,
            num: 11,
            rusts_on: '4',
            variants: [
              {
                name: '1+2',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 1, 'visit' => 1 }],
                track_type: :narrow,
                no_local: true,
                price: 100,
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            num: 9,
            rusts_on: '6',
            variants: [
              {
                name: '2+3',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 2, 'visit' => 2 }],
                track_type: :narrow,
                price: 200,
              },
            ],
            events: [{ 'type' => 'south_majors_available' },
                     { 'type' => 'companies_bought_150' }],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            num: 7,
            rusts_on: '8',
            variants: [
              {
                name: '3+4',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 3, 'visit' => 3 }],
                track_type: :narrow,
                price: 300,
              },
            ],
            events: [
              { 'type' => 'companies_bought_200' },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 5,
            variants: [
              {
                name: '4+5',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 4, 'visit' => 4 }],
                track_type: :narrow,
                price: 500,
              },
            ],
            events: [{ 'type' => 'close_companies' },
                     { 'type' => 'minors_stop_operating' },
                     { 'type' => 'float_60' }],
          },
          {
            name: '6',
            distance: 6,
            price: 600,
            num: 3,
            variants: [
              {
                name: '5+6',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 5, 'visit' => 5 }],
                track_type: :narrow,
                price: 600,
              },
            ],
          },

          {
            name: '8',
            distance: 8,
            price: 800,
            num: 30,
            variants: [
                      {
                        name: '6+8',
                        distance: [{ 'nodes' => %w[town halt], 'pay' => 8, 'visit' => 8 },
                                   { 'nodes' => %w[city offboard town halt], 'pay' => 6, 'visit' => 6 }],
                        track_type: :narrow,
                        price: 800,
                      },
                    ],

          },
          ].freeze

        # These trains don't count against train limit, they also don't count as a train
        # against the mandatory train ownership. They cant the bought by another corporation.
        EXTRA_TRAINS = %w[2P].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
                'south_majors_available' => ['South Majors Available',
                                             'Major Corporations in the south map can open'],
                'companies_bought_150' => ['Companies 150%', 'Companies can be bought in for maximum 150% of value'],
                'companies_bought_200' => ['Companies 200%', 'Companies can be bought in for maximum 200% of value'],
                'minors_stop_operating' => ['Minors stop operating'],
                'float_60' => ['60% to Float', 'Corporations must have 60% of their shares sold to float'],
              ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
                'can_buy_trains' => ['Buy trains', 'Can buy trains from other corporations'],
                'mountain_pass' => ['Mountain pass', 'Can build mountain passes'],
                'lay_second_tile' => ['Tile Lay', 'Northern corporations can lay a second tile'],
                'higher_par_prices' => ['Higher Par Prices', 'Northern corporations can now par at 95 and 100'],
              ).freeze

        def init_corporations(stock_market)
          game_corporations.map do |corporation|
            G18ESP::Corporation.new(
              self,
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end
        end

        def init_tile_groups
          self.class::TILE_GROUPS
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18ESP::Step::CompanyPendingPar,
            G18ESP::Step::SelectionAuction,
          ])
        end

        def stock_round
          G18ESP::Round::Stock.new(self, [
            G18ESP::Step::Acquire,
            G18ESP::Step::DiscardTrain,
            G18ESP::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G18ESP::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Assign,
            Engine::Step::Exchange,
            Engine::Step::SpecialToken,
            G18ESP::Step::BuyCarriageOrCompany,
            G18ESP::Step::Choose,
            G18ESP::Step::HomeToken,
            G18ESP::Step::SpecialTrack,
            G18ESP::Step::SpecialChoose,
            G18ESP::Step::Track,
            G18ESP::Step::Route,
            G18ESP::Step::Dividend,
            G18ESP::Step::DiscardTrain,
            G18ESP::Step::Acquire,
            G18ESP::Step::BuyTrain,
            G18ESP::Step::CombinedTrains,
            [G18ESP::Step::BuyCarriageOrCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def p2
          @p2 ||= company_by_id('P2')
        end

        def p3
          @p3 ||= company_by_id('P3')
        end

        def p4
          @p4 ||= company_by_id('P4')
        end

        def p5
          @p5 ||= company_by_id('P5')
        end

        def mza
          @mza ||= corporation_by_id('MZA')
        end

        def madrid_hex
          @madrid_hex ||= hex_by_id(MADRID_HEX)
        end

        def setup
          @future_corporations = @corporations.select do |corporation|
            corporation.type != :minor && !north_corp?(corporation)
          end
          @corporations.each { |c| c.shares.first.double_cert = true if c.type == :minor }

          @company_trains = {}
          @company_trains['P2'] = find_and_remove_train_for_minor(P2_TRAIN_ID, buyable: false)
          @company_trains['P3'] = find_and_remove_train_for_minor(P3_TRAIN_ID, buyable: false)
          @perm2_ran_aranjuez = false

          setup_company_price(1)

          @luxury_carriages = { 'P5' => 5, 'bank' => 0 }

          @opened_mountain_passes = []
          @combined_trains = {}

          @tile_groups = init_tile_groups
          initialize_tile_opposites!
          @unused_tiles = []

          # place tokens on mountain passes

          MOUNTAIN_PASS_TOKEN_HEXES.each do |hex|
            block_token = Token.new(nil, price: 0, logo: '/logos/18_esp/block.svg')
            hex_by_id(hex).tile.cities.first.exchange_token(block_token)
            hex_by_id(hex).tile.cities.first.exchange_token(block_token)
          end
          remove_extra_corporation_destination_icons if core
        end

        def setup_corporations
          minors, majors = @corporations.partition { |corporation| corporation.type == :minor }
          north_majors, south_majors = majors.partition { |corporation| north_corp?(corporation) }
          remove_corps = north_majors.sort_by { rand }.take(2) + south_majors.sort_by { rand }.take(3) + minors.sort_by do
                                                                                                           rand
                                                                                                         end.take(3)
          @log << "Removing #{remove_corps.map(&:name).join(', ')}"
          remove_corps.each do |c|
            @corporations.delete(c)
            hex = @hexes.find { |h| h.id == c.coordinates }
            hex.tile.cities[c.city || 0].remove_reservation!(c)
            hex.tile.remove_reservation!(c)
            hex.tile.cities[c.city || 0].remove_tokens!
            destination_hex = @hexes.find { |h| h.id == c.destination }
            destination_hex.tile.icons.reject! { |icon| icon.name == c.name } if destination_hex
            c.close!
          end
        end

        def setup_companies
          remove_company_name = @corporations.none? { |c| c.name == 'CRB' } ? 'Zafra - Huelva' : 'Ferrocarril Vasco-Navarro'
          remove_company = @companies.find { |c| c.name == remove_company_name }
          @log << "Removing #{remove_company_name}"
          @companies.delete(remove_company)
        end

        def setup_preround
          setup_corporations unless core
          setup_companies
        end

        def remove_extra_corporation_destination_icons
          self.class::EXTRA_CORPORATIONS.each do |c|
            next unless c[:destination]

            tile = hex_by_id(c[:destination]).tile
            tile.icons.reject! { |icon| icon.name == c[:sym] }
          end
        end

        def remove_unlaunched_corporation_destination_icons
          @corporations.each do |c|
            next if c.type == :minor
            next if c.ipoed
            next unless c.destination

            tile = hex_by_id(c.destination).tile
            tile.icons.reject! { |icon| icon.name == c.name }
          end
        end

        def setup_company_price(mulitplier)
          @companies.each { |company| company.max_price = company.value * mulitplier }
        end

        def init_stock_market
          Engine::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                  multiple_buy_types: self.class::MULTIPLE_BUY_TYPES,
                                  zigzag: :flip)
        end

        def operating_order
          @corporations.select(&:floated?).sort
        end

        def find_and_remove_train_for_minor(train_id, buyable = true)
          train = train_by_id(train_id)
          @depot.remove_train(train)
          train.buyable = buyable
          train.reserved = true
          train
        end

        def init_company_abilities
          northern_corps = @corporations.select { |c| north_corp?(c) }
          #  the PRNG doesn't work well when doing mod even numbers, as
          # the lower digits aren't truly random. Right shifting by 12 fixes the issue.
          random_corporation = northern_corps[(rand >> 12) % northern_corps.size]
          another_random_corporation = northern_corps[(rand >> 12) % northern_corps.size]
          @companies.each do |company|
            next unless (ability = abilities(company, :shares))

            real_shares = []
            ability.shares.each do |share|
              case share
              when 'random_president'
                share = random_corporation.shares[0]
                real_shares << share
                company.desc = "Purchasing player takes a president's share (20%) of #{random_corporation.name} \
                (The president's share is randomized) and immediately sets its par value. \
                It closes when #{random_corporation.name} buys its first train."
                @log << "#{company.name} comes with the president's share of #{random_corporation.name}"
                company.add_ability(Ability::Close.new(
                type: :close,
                when: 'bought_train',
                corporation: random_corporation.name,
              ))
              when 'random_share'
                share = another_random_corporation.shares.find { |s| !s.president }
                real_shares << share
                company.desc = "It provides a 10% certificate from a random corporation. \
                The random corporation in this game is #{another_random_corporation.name}."
                @log << "#{company.name} comes with a #{share.percent}% share of #{another_random_corporation.name}"
              else
                real_shares << share_by_id(share)
              end
            end

            ability.shares = real_shares
          end
        end

        def tile_lays(entity)
          return MINOR_TILE_LAYS if entity.type == :minor || (north_corp?(entity) && !@phase.status.include?('lay_second_tile'))

          MAJOR_TILE_LAYS
        end

        def north_corp?(entity)
          return false unless entity&.corporation?

          NORTH_CORPS.include? entity.name
        end

        def event_south_majors_available!
          @future_corporations = []
          @can_acquire_minors = true
          @log << '-- Major corporations in the south now available --'
        end

        def event_companies_bought_150!
          setup_company_price(1.5)
        end

        def event_companies_bought_200!
          setup_company_price(2)
        end

        def event_can_buy_trains!
          @log << 'Corporations can buy trains from other corporations'
          @can_buy_trains = true
        end

        def event_minors_stop_operating!
          @log << 'All Minors close'
          close_all_minors
        end

        def game_end_check_second_eight?
          # game end on second 8 train purhcase
          return false unless @phase&.phases&.last == @phase&.current

          train_sym = @depot.upcoming.first.sym
          remaining = @depot.upcoming.size
          total = @depot.trains.count { |t| t.sym == train_sym }

          end_game_trigger = total - remaining > 1

          if end_game_trigger && !@game_ending
            @log << '-- Event: Endgame triggered --'
            @log << "Finish this OR; Game ends at the end of #{@turn + 1}.#{@operating_rounds}"
            @operating_rounds = @round.round_num
            @game_ending = true
          end
          end_game_trigger
        end

        def event_close_companies!
          @log << '-- Event: Private companies close --'
          @luxury_carriages['P5'] = 0 # no more luxury carriage buying
          @companies.each do |company|
            convert_p3_into_2p if company == p3 && company.owner.is_a?(Corporation)
            company.close!
          end
          remove_unlaunched_corporation_destination_icons # remove unlaunched dest icons
        end

        def event_float_60!
          @corporations.each do |c|
            next if c.type == :minor

            c.float_percent = 60

            next if c.floated?

            # release tokens
            c.tokens.each { |token| token.used = false if token.used == true && !token.hex }
            # all goals reached, no extra cap
            c.destination_connected = true
            c.ran_offboard = true
            c.ran_harbor = true
            c.full_cap = true
          end

          @full_cap = true
        end

        def float_corporation(corporation)
          share_count = 10 if @full_cap
          @log << "#{corporation.name} floats"
          share_count ||= corporation.type == :major ? 4 : 2

          @bank.spend(corporation.par_price.price * share_count, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end

        def home_token_can_be_cheater
          true
        end

        def north_hex?(hex)
          hex.y < NORTH_SOUTH_DIVIDE
        end

        def mine_hexes
          @mine_hexes ||= Map::MINE_HEXES
        end

        def mine_hex?(hex)
          mine_hexes.any?(hex.name)
        end

        def status_array(corporation)
          return if corporation.type == :minor

          return availability_status_array if @future_corporations.include?(corporation)

          goal_status = ['Goals Left:']

          goal_status << ["Destination #{corporation.destination}"] unless corporation.destination_connected?
          goal_status << ['Offboard'] unless corporation.ran_offboard?
          goal_status << ['Run to harbor'] unless corporation.ran_harbor

          goal_status = [] if goal_status.length == 1

          train_status = corporation.trains.map do |train|
            next unless combined_trains[train]

            "Combined train #{train.name}: #{combined_trains[train]}"
          end
          train_status = [] if train_status.length.zero?
          status = goal_status + train_status
          status = nil if status.length.zero?
          status
        end

        def availability_status_array
          ['Available on Phase 3']
        end

        def company_status_str(company)
          return if company != p5 || p5.owner.nil? || p5.owner.corporation?

          "#{@luxury_carriages[p5.id]} / 5 Buyable Tenders"
        end

        def upgrade_cost(old_tile, hex, entity, spender)
          total_cost = super
          total_cost += MINE_CLOSE_COST if old_tile.towns.any?(&:halt?) && old_tile.color == :yellow
          total_cost
        end

        def upgrades_to_correct_city_town?(from, to)
          return false if from.halts.size != to.halts.size && from.color == :white

          # honors existing town/city counts and connections?
          # - allow labelled cities to upgrade regardless of count; they're probably
          #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
          # - TODO: account for games that allow double dits to upgrade to one town
          return false if from.towns.count { |t| !t.halt? } != to.towns.count { |t| !t.halt? }
          return false if !from.label && from.cities.size != to.cities.size && !upgrade_ignore_num_cities(from)
          return false if from.cities.size > 1 && to.cities.size > 1 && !from.city_town_edges_are_subset_of?(to.city_town_edges)

          # but don't permit a labelled city to be downgraded to 0 cities.
          return false if from.label && !from.cities.empty? && to.cities.empty?

          # handle case where we are laying a yellow OO tile and want to exclude single-city tiles
          return false if (from.color == :white) && from.label.to_s == 'OO' && from.cities.size != to.cities.size

          true
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          # correct color progression?
          return false unless upgrades_to_correct_color?(from, to, selected_company: selected_company)

          return false unless check_paths_are_subset_of?(from, to)

          # If special ability then remaining checks is not applicable
          return true if special

          # correct label?
          return false unless upgrades_to_correct_label?(from, to)

          # correct number of cities and towns
          return false unless upgrades_to_correct_city_town?(from, to)

          true
        end

        def check_paths_are_subset_of?(from, to)
          return from.paths_are_subset_of?(to.paths) if from.towns.none?(&:halt?)

          other_exits = to.paths.flat_map(&:exits).uniq
          [0, 1, 2, 3, 4, 5].any? { |ticks| (from.exits - other_exits.map { |e| (e + ticks) % 6 }).empty? }
        end

        def subsidy_for(route, stops)
          count = stops.count { |stop| stop.halt? && stop.tile.color != :blue }
          harbor_subsidy = stops.sum { |stop| stop.tile.color == :blue ? stop.route_revenue(route.phase, route.train) : 0 }
          mine_subsidy = count * BASE_MINE_BONUS[@phase.tiles.last]
          harbor_subsidy + mine_subsidy
        end

        def routes_subsidy(routes)
          routes.sum(&:subsidy)
        end

        def check_for_destination_connection(entity)
          return false unless entity&.corporation?
          return true if entity.destination_connected?

          graph = Graph.new(self, no_blocking: true)
          graph.compute(entity)
          graph.reachable_hexes(entity).include?(hex_by_id(entity.destination))
        end

        def check_offboard_goal(entity, routes)
          return false unless entity.corporation?
          return false if entity.type == :minor
          return true if entity.ran_offboard?

          # logic to check if routes include offboard
          routes.any? { |route| route.visited_stops.any?(&:offboard?) }
        end

        def check_harbor_goal(entity, routes)
          return false unless entity.corporation?
          return false if entity.type == :minor
          return true if entity.ran_harbor

          # logic to check if routes contains harbor
          routes.any? do |route|
            route.stops.any? { |stop| stop.tile.color == :blue }
          end
        end

        def mountain_pass_token_hex?(hex)
          MOUNTAIN_PASS_TOKEN_HEXES.include?(hex.id)
        end

        def check_distance(route, visits)
          entity = route.corporation

          if entity.type == :minor && visits.any?(&:offboard?)
            raise GameError,
                  'Minors can not run to offboard locations'
          end

          if combined_trains.key?(route.train)
            raise GameError, 'Combined train must run through a montain pass' if route.hexes.none? do |hex|
                                                                                   mountain_pass_token_hex?(hex)
                                                                                 end

            north_stops = route.stops.count { |st| north_hex?(st.hex) && !mountain_pass_token_hex?(st.hex) }
            south_stops = route.stops.count { |st| !north_hex?(st.hex) && !mountain_pass_token_hex?(st.hex) }

            raise GameError, 'Combined train must stop at both maps' if !north_stops.positive? || !south_stops.positive?

          end

          raise GameError, 'Route can only use one mountain pass' if route.hexes.count { |hex| mountain_pass_token_hex?(hex) } > 1

          hexes = route.hexes.reject { |h| self.class::DOUBLE_HEX.include?(h.name) }
          raise GameError, 'Route visits same hex twice' if hexes.size != hexes.uniq.size

          if route.train.id == '2P-0' && !@perm2_ran_aranjuez && !p2_route_runs_aranjuez_to_mardid?(route)
            raise GameError,
                  '2P first run must include Aranjuez and Madrid'
          end
          wrong_track = skip_route_track_type(route.train)
          raise GameError, 'Routes must use correct gauage' if wrong_track && route.paths.any? { |p| p.track == wrong_track }

          super
        end

        def check_p2_aranjuez(routes)
          return if @perm2_ran_aranjuez

          @perm2_ran_aranjuez = routes.any? do |route|
            p2_route_runs_aranjuez_to_mardid?(route)
          end
        end

        def p2_route_runs_aranjuez_to_mardid?(route)
          route.train.id == '2P-0' &&
          ([ARANJUEZ_HEX, MADRID_HEX] - route.hexes.map(&:id)).empty?
        end

        def valid_interchange?(tile, entity)
          track_type = north_corp?(entity) ? :broad : :narrow
          uniq_tracks = tile.paths.map(&:track).uniq
          uniq_tracks.include?(:dual) || uniq_tracks.include?(track_type)
        end

        def revenue_for(route, stops)
          revenue = stops.sum { |stop| stop.halt? ? 0 : stop.route_revenue(route.phase, route.train) }
          bonus = route.hexes.sum do |hex|
            tokened_mountain_pass(hex, route.train.owner) ? MOUNTAIN_PASS_TOKEN_BONUS[hex.id] : 0
          end
          revenue += bonus

          if east_west_bonus(stops)[:revenue].positive? && gbi_bm_bonus(stops)[:revenue].positive?
            revenue += COMBINED_BONUS
          else
            revenue += east_west_bonus(stops)[:revenue]
            revenue += gbi_bm_bonus(stops)[:revenue]
          end

          revenue *= 2 if final_ors? && @round.round_num == @operating_rounds && north_corp?(route.train.owner)

          revenue
        end

        def east_west_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.tile.label&.to_s == 'E' }
          west = stops.find { |stop| stop.tile.label&.to_s == 'W' }

          if east && west
            bonus[:revenue] += BONUS
            bonus[:description] = 'E/W'
          end

          bonus
        end

        def gbi_bm_bonus(stops)
          bonus = { revenue: 0 }

          bm = stops.find { |stop| %w[M B].include?(stop.tile.label&.to_s) }
          gbi = stops.find { |stop| stop.hex.id == 'E3' || stop.hex.id == 'K5' }
          if bm && gbi
            bonus[:revenue] += BONUS
            bonus[:description] = 'G/Bi to B/M'
          end

          bonus
        end

        def tokened_mountain_pass(hex, entity)
          mountain_pass_token_hex?(hex) &&
          hex.tile.stops.first.tokened_by?(entity)
        end

        def revenue_str(route)
          rev_str = super
          rev_str += ' + mountain pass' if route.hexes.any? { |hex| mountain_pass_token_hex?(hex) }

          ewbonus = east_west_bonus(route.stops)[:description]
          rev_str += " + #{ewbonus}" if ewbonus

          bonus = gbi_bm_bonus(route.stops)[:description]
          rev_str += " + #{bonus}" if bonus

          rev_str
        end

        def must_buy_train?(entity)
          entity.trains.none? { |t| !extra_train?(t) } &&
          !depot.depot_trains.empty?
        end

        def num_corp_trains(entity)
          type_to_ignore = north_corp?(entity) ? :broad : :narrow
          entity.trains.count { |t| t.track_type != type_to_ignore }
        end

        def place_home_token(corporation)
          if corporation == mza && !corporation.tokens.first.used
            token = corporation.tokens.first
            hex = hex_by_id(corporation.coordinates)
            cities = hex.tile.cities
            city =
              if cities.one?
                cities.first
              else
                cities[corporation.city]
              end
            @log << "#{corporation.name} places a token on #{hex.id}"
            cheater = !city.tokenable?(corporation)
            city.place_token(corporation, token, cheater: cheater, check_tokenable: false)
          else
            super
          end
          clear_graph_for_entity(corporation)
          corporation.goal_reached!(:destination) if check_for_destination_connection(corporation)
        end

        def rust_trains!(train, _entity)
          reserved_2t = train_by_id(P2_TRAIN_ID)
          return super unless reserved_2t

          @depot.reclaim_train(reserved_2t) if rust?(reserved_2t, train)
          super
        end

        def company_bought(company, entity)
          # # On acquired abilities
          transfer_luxury_ability(company, entity) if company == p5
        end

        def transfer_luxury_ability(company, entity)
          transfer_tenders_to_bank
          luxury_ability = company.all_abilities.first
          if luxury_ability(entity)
            # entity already has tender. Do not add, but increase carriage count
            @luxury_carriages['bank'] += 1
            @log << "#{entity.name} already has a tender, extra tender is returned to the bank and can be purchased"
          else
            entity.add_ability(luxury_ability)
            @log << "#{entity.name} can now assign tender to a single train"
          end
          company.remove_ability(luxury_ability)
          company.close!
        end

        def transfer_tenders_to_bank
          @luxury_carriages.dup.each do |owner, amount|
            next if owner == 'bank'

            transfer_amount = amount
            @luxury_carriages['bank'] += transfer_amount
            @luxury_carriages[owner] = 1
          end
        end

        def luxury_ability(entity)
          entity.abilities.find { |a| a.description == 'Tender' }
        end

        def convert_p3_into_2p
          train = @company_trains[p3.id]
          buy_train(p3.owner, train, :free)
          @log << "#{p3.owner.name} gains a #{train.name} train"
          @company_trains.delete(p3.id)
        end

        def on_acquired_train(entity, train_variant)
          company_id = @p2.id
          @log << "#{@p2.name} closes"
          @p2.close!

          train = @company_trains[company_id]
          if train.rusted
            @log << 'train 2/1+2 has rusted, train is discarded'
            return
          end

          train.variant = train_variant
          train.operated = true
          buy_train(entity, train, :free)
          @log << "#{entity.name} gains a #{train.name} train"

          @company_trains.delete(company_id)
        end

        def get_or_revenue(info)
          !info.dividend.is_a?(Action::Dividend) || info.dividend.kind == 'withhold' ? 0 : info.revenue
        end

        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              or_round_finished
              skip_pre_final_or = game_end_check_second_eight? && !final_ors?
              if @round.round_num < @operating_rounds && !skip_pre_final_or
                new_operating_round(@round.round_num + 1)
              else
                or_set_finished
                @turn += 1
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players(:least_cash, log_player_order: true)
              new_stock_round
            end
        end

        def or_set_finished
          @depot.export! if @corporations.any?(&:floated?)
          game_end_check
        end

        def final_ors?
          @turn == @final_turn && @round.is_a?(Round::Operating)
        end

        def holder_for_corporation(_entity)
          # Incremental corps DON'T get paid from IPO shares.
          @game.share_pool
        end

        def next_sr_player_order
          @round_counter.zero? ? :least_cash : :most_cash
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def remove_dest_icon(corp)
          return unless corp.destination

          tile = hex_by_id(corp.destination).tile
          tile.icons.reject! { |icon| icon.name == corp.name }
        end

        def extra_train?(train)
          self.class::EXTRA_TRAINS.include?(train.name)
        end

        def crowded_corps
          @crowded_corps ||= corporations.select do |c|
            trains = c.trains.count { |t| !extra_train?(t) }
            trains > train_limit(c)
          end
        end

        def corporation_available?(corp)
          @future_corporations.none?(corp)
        end

        def sorted_corporations
          # Corporations sorted by some potential game rules
          ipoed, others = corporations.partition(&:ipoed)
          corps = others - @future_corporations

          ipoed.sort + corps + @future_corporations
        end

        def skip_route_track_type(train)
          case train.track_type
          when :narrow
            :broad
          when :broad
            :narrow
          end
        end

        def open_mountain_pass(entity, pass_hex_id, p4_ability = false)
          pass_hax = hex_by_id(pass_hex_id)
          pass_tile = pass_hax.tile

          mount_pass_cost = mountain_pass_token_cost(pass_hax, entity, p4_ability)
          entity.spend(mount_pass_cost, @bank) if mount_pass_cost.positive?

          @opened_mountain_passes << pass_hax.id
          pass_tile.cities.first.remove_tokens!

          entity_name = p4_ability ? "#{entity.name} (#{p4.name})" : entity.name

          @log << "#{entity_name} spends #{format_currency(mount_pass_cost)} to open mountain pass"
        end

        def opening_new_mountain_pass(entity, p4_ability = false)
          return {} unless entity

          @graph.clear
          openable_passes = @graph.connected_hexes(entity).keys.select do |hex|
            mountain_pass_token_hex?(hex)
          end
          openable_passes = openable_passes.reject { |hex| @opened_mountain_passes.include?(hex.id) }

          openable_passes.to_h do |hex|
            [hex.id, "#{hex.location_name} (#{format_currency(mountain_pass_token_cost(hex, entity, p4_ability))})"]
          end
        end

        def mountain_pass_token_cost(hex, _entity, p4_ability = false)
          return 0 if hex.id == P4_HEX && p4_ability

          cost = MOUNTAIN_PASS_TOKEN_COST[hex.id]
          cost -= P4_DISCOUNT if p4_ability
          cost
        end

        def start_merge(corporation, minor, keep_token)
          # pay compensation
          pay_compensation(corporation, minor)

          # take over assets
          move_assets(corporation, minor)

          # handle token
          swap_token(corporation, minor) if keep_token

          # get share
          get_reserved_share(minor.owner, corporation) if minor.ipoed

          # gain tender ability
          gain_luxury_carriage_ability_from_minor(corporation, minor)

          # close corp
          close_corporation(minor)
        end

        def close_corporation(corporation, quiet: false)
          if corporation.type == :minor
            corporation.placed_tokens.each do |token|
              city = token.city
              remove_slot = city.tokens.compact.any?(&:cheater)
              city.delete_token!(token, remove_slot: remove_slot)
            end
          end
          super
        end

        def southern_major_corps
          @corporations.select { |c| c.type == :major && !north_corp?(c) }
        end

        def close_all_minors
          @corporations.dup.each do |c|
            next unless c.type == :minor

            if c.operated?
              @bank.spend(c.share_price.price, c.owner)
              @log << "#{c.owner.name} recieves compensation of #{format_currency(c.share_price.price)} for #{c.name}"
            end
            close_minor(c)
          end
        end

        def close_minor(c)
          hex = hex_by_id(c.coordinates)
          c.tokens.first.remove!
          hex.tile.cities.each do |city|
            city.remove_reservation!(c)
          end
          hex.tile.remove_reservation!(c)
          @log << "#{c.name} closes"

          c.share_holders.each_key do |share_holder|
            share_holder.shares_by_corporation.delete(c)
          end

          @share_pool.shares_by_corporation.delete(c)
          c.share_price&.corporations&.delete(c)

          @corporations.delete(c)
          c.set_cash(0, @bank)
          c.close!
        end

        def pay_compensation(corporation, minor)
          if minor.player_share_holders.empty?
            corporation.spend(MINOR_TAKEOVER_COST, @bank)
            @log << "#{corporation.name} spends #{format_currency(MINOR_TAKEOVER_COST)} to acquire #{minor.name}"
          else
            share_price = minor.share_price
            payout = share_price ? minor.share_price.price : 0

            corporation.spend(payout, minor.owner)

            @log << "#{minor.owner.name} gets #{format_currency(payout)} compensation"
          end
        end

        def get_reserved_share(owner, corporation)
          reserved_share = corporation.shares.last
          return unless reserved_share

          @share_pool.transfer_shares(
              reserved_share.to_bundle,
              owner,
              allow_president_change: true,
              price: 0
            )
          @log << "#{owner.name} gets a share of #{corporation.name}"
        end

        def gain_luxury_carriage_ability_from_minor(corporation, minor)
          minor_luxury_ability = luxury_ability(minor)
          return unless minor_luxury_ability

          if luxury_ability(corporation)
            @luxury_carriages['bank'] += 1
            @log << "#{corporation.name} already has a tender. The additional \
            tender can be bought by another company from the bank"
          else
            corporation.add_ability(minor_luxury_ability)
            @log << "#{corporation.name} gains tender from #{minor.name}"
          end
        end

        def delete_token_mz(minor)
          token = minor.tokens.first
          return unless token.used

          city = token.city
          yellow_green = city.tile.color == :yellow || city.tile.color == :green
          if !yellow_green
            delete_slot = city.slots > 4 ? city.slots : false
            city.delete_token!(token, remove_slot: delete_slot)
            # add MZA reservation if MZA not tokened in madrid yet
            mza_token = city.tokens.compact.find { |t| t.corporation == mza }
            city.add_reservation!(mza) unless mza_token
            token.destroy!
          else
            # check if there's another slot
            delete_slot = city.slots > 1 ? city.slots : false
            # check if slot is already used, if not reserve
            corp = @corporations.find { |c| c.city == city.index && c.name != 'MZ' }

            city.delete_token!(token, remove_slot: delete_slot)
            city.add_reservation!(corp) unless delete_slot
          end
        end

        def swap_token(survivor, nonsurvivor)
          new_token = survivor.next_token
          old_token = nonsurvivor.tokens.first
          city = old_token.city
          if city.nil?
            city = hex_by_id(nonsurvivor.coordinates).tile.cities.find { |c| c.reserved_by?(nonsurvivor) }
            city.remove_reservation!(nonsurvivor)
          end

          @log << "Replaced #{nonsurvivor.name} token in #{city.hex.id} with #{survivor.name}"\
                  ' token'

          if nonsurvivor.ipoed
            new_token.place(city)
            city.tokens[city.tokens.find_index(old_token)] = new_token
            nonsurvivor.tokens.delete(old_token)
          else
            city.place_token(survivor, new_token)
          end
        end

        def move_assets(survivor, nonsurvivor)
          # cash
          nonsurvivor.spend(nonsurvivor.cash, survivor) if nonsurvivor.cash.positive?
          # trains
          nonsurvivor.trains.each { |t| t.owner = survivor }
          survivor.trains.concat(nonsurvivor.trains)
          nonsurvivor.trains.clear
          survivor.trains.each { |t| t.operated = false }
          # privates
          nonsurvivor.companies.each do |c|
            c.owner = survivor
            survivor.companies << c
          end
          nonsurvivor.companies.clear

          @log << "Moved assets from #{nonsurvivor.name} to #{survivor.name}"
        end

        def combined_base_trains_candidates(corporation)
          return unless corporation

          corporation.trains.reject { |t| combined_trains.key?(t) || t.name == '2P' }
        end

        def combined_obsolete_trains_candidates(corporation)
          return unless corporation

          rusted_trains = @depot.trains.select do |train|
            train.rusted && corporation.cash >= 2 * train.price
          end

          rusted_trains.uniq { |train| train.variants.keys[0] }
        end

        def update_trains_cache
          update_cache(:trains)
        end

        def distance(train)
          if train.distance.is_a?(Numeric)
            [train.distance, 0]
          else
            cities = train.distance[1]['pay']
            towns = train.distance[0]['pay']
            [cities, towns]
          end
        end

        def core
          @optional_rules&.include?(:core)
        end

        def game_corporations
          corps = self.class::CORPORATIONS
          corps += self.class::EXTRA_CORPORATIONS unless core
          corps
        end

        def can_only_run_narrow?(entity)
          return unless entity.corporation?
          return false if entity.type == :minor
          return false unless north_corp?(entity)

          !entity.southern_token?
        end

        def can_only_run_broad?(entity)
          return unless entity.corporation?
          return true if entity.type == :minor
          return false if north_corp?(entity)

          !entity.northern_token?
        end

        def combined_train_blocked?(entity)
          return if entity.trains.none? { |t| t.track_type == :all }

          graph_for_entity(entity).connected_nodes(entity).keys.none? do |n|
            mountain_pass_token_hex?(n.hex) && !n.blocks?(entity)
          end
        end

        def check_overlap(routes)
          tracks = {}

          check = lambda do |key|
            raise GameError, "Route cannot reuse track on #{key[0].id}" if tracks[key]

            tracks[key] = true
          end

          routes.each do |route|
            route.paths.each do |path|
              a = path.a
              b = path.b

              check.call([path.hex, a.num, path.lanes[0][1]]) if a.edge?
              check.call([path.hex, b.num, path.lanes[1][1]]) if b.edge?

              # check intra-tile paths between nodes
              check.call([path.hex, path]) if path.nodes.size > 1
            end
          end
        end

        def other_bank_info
          return unless (@luxury_carriages['bank']).positive?

          ['Tenders', (@luxury_carriages['bank']).to_s]
        end
      end
    end
  end
end
