# frozen_string_literal: true

require_relative '../g_1867/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'graph'
require_relative '../base'
require_relative '../company_price_up_to_face'
require_relative '../../loan'
require_relative '../interest_on_loans'

module Engine
  module Game
    module G1812
      class Game < G1867::Game
        include_meta(G1812::Meta)
        include Entities
        include Map
        include CompanyPriceUpToFace
        include InterestOnLoans

        TRACK_RESTRICTION = :semi_restrictive
        CURRENCY_FORMAT_STR = '£%s'

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block_pres

        BANK_CASH = { 2 => 4000, 3 => 6000, 4 => 8000 }.freeze

        CERT_LIMIT = { 2 => 15, 3 => 10, 4 => 10 }.freeze

        STARTING_CASH = 195

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        GAME_END_CHECK = { bank: :current_or }.freeze

        COLUMN_MARKET = [
          %w[40 45 50x 55x 60x 65p 70p 80p 90p 100pC 110zC 120zC 135zC 150m 165 180 200 220 245 270 300 330 360 400],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies minors_can_merge],
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: %w[can_buy_companies minors_can_merge cannot_open_minors],
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 0, major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %w[minors_can_merge cannot_open_minors],
          },
          {
            name: '6',
            on: '3D',
            train_limit: { minor: 0, major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %w[minors_can_merge cannot_open_minors],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 8,
            variants: [
              {
                name: '1G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 1, 'visit' => 1 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 90,
                no_local: true, # runs port, city and mine, not a single-city local route
              },
            ],
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 200,
            rusts_on: '5',
            variants: [
              {
                name: '2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 180,
              },
            ],
            events: [{ 'type' => 'three_trains_will_convert' }],
          },
          {
            name: '3+1',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 1, 'visit' => 99 }],
            price: 220,
            rusts_on: '3D',
            num: 5,
            variants: [
              {
                name: '2+1G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => ['town'], 'pay' => 1, 'visit' => 99 }],
                price: 200,
              },
            ],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 400,
            variants: [
              {
                name: '3+2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 2, 'visit' => 99 }],
                price: 360,
              },
            ],
            events: [{ 'type' => 'majors_can_ipo' },
                     { 'type' => 'minors_cannot_start' }],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 500,
            num: 10,
            variants: [
              {
                name: '4+2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 2, 'visit' => 99 }],
                price: 460,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '3D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 99, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 750,
            num: 10,
            available_on: '5',
            variants: [
              {
                name: '2+2GD',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 99, 'multiplier' => 2 },
                           { 'nodes' => ['town'], 'pay' => 2, 'visit' => 99, 'multiplier' => 2 }],
                price: 460,
              },
            ],
          },
        ].freeze

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1867::Step::SingleItemAuction,
          ])
        end

        def stock_round
          G1867::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1867::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          calculate_interest
          G1867::Round::Operating.new(self, [
            Engine::Step::BuyCompany,
            G1867::Step::RedeemShares,
            G1867::Step::Track,
            G1867::Step::Token,
            Engine::Step::Route,
            G1867::Step::Dividend,
            [G1867::Step::BuyCompanyPreloan, { blocks: true }],
            G1812::Step::LoanOperations,
            Engine::Step::DiscardTrain,
            G1812::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        EVENTS_TEXT = G1867::Game::EVENTS_TEXT.merge('three_trains_will_convert' => ['Unsold 3/2G will convert to 3+1/2G+1',
                                                                                     'At the end of the OR set when the first '\
                                                                                     '3/2G train is purchased, all remaining '\
                                                                                     'trains of that rank are converted to '\
                                                                                     '3+1/2G+1 trains']).freeze

        # this is used in 1867 to label the National railway, which isn't present in 1812
        def corporation_size_name(entity); end

        # 1812 doesn't have 1867's nationalization mechanic
        def nationalize!(corporation); end

        # this method is called in the buy_train_action method of the buy_train step imported from 1867.
        # it isn't used in 1812, so it's defined here to do nothing
        def post_train_buy; end

        def new_or!
          if @round.round_num < @operating_rounds
            new_operating_round(@round.round_num + 1)
          else
            @turn += 1
            or_set_finished
            new_stock_round
          end
        end

        def merger_round
          G1867::Round::Merger.new(self, [
            G1867::Step::ReduceTokens,
            G1867::Step::PostMergerShares,
            Engine::Step::DiscardTrain,
            G1812::Step::Merge,
          ], round_num: @round.round_num)
        end

        def next_round!
          clear_interest_paid
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              if phase.name.to_i == 2
                new_or!
              else
                new_merger_round
              end
            when G1867::Round::Merger
              new_or!
            when init_round.class
              reorder_players
              new_stock_round
            end
        end

        def or_set_finished
          depot.export_all!('2') if @phase.name.to_i == 2 &&
                                    (@depot.upcoming.first != train_by_id('2-0') &&
                                     @depot.upcoming.first != train_by_id('3-0'))

          return unless @convert_3s == true

          replace_three_with_three_plus_one
        end

        def replace_three_with_three_plus_one
          trains_3t = depot.upcoming.select { |t| t.name == '3' }
          return unless trains_3t

          @log << '--All remaining 3/2G trains in the supply replaced with 3+1/2G+1 trains--'
          trains_3t.zip(@three_plus_one) do |t3, t3plus|
            depot.forget_train(t3)
            t3plus.reserved = false
            @depot.insert_train(t3plus)
          end
          @convert_3s = false
        end

        def init_train_handler
          depot = super

          # store the 3+1 trains in reserve for now

          @three_plus_one = depot.upcoming.select { |t| t.name == '3+1' }
          @three_plus_one.each do |train|
            depot.remove_train(train)
            train.reserved = true
          end

          depot
        end

        def setup
          @interest = {}
          setup_company_price_up_to_face
          @show_majors = false
          @convert_3s = false

          @north_south_bonus = hex_by_id(NORTH_SOUTH_BONUS_HEX).tile.offboards.first
          @port_mine_bonus = hex_by_id(PORT_MINE_BONUS_HEX).tile.offboards.first
          self.class::MINE_ONLY_HEXES.each { |id| add_mine_node(hex_by_id(id).tile) }
        end

        def setup_preround
          setup_companies
          setup_minors if remove_some_minors?
          setup_corps
        end

        def setup_companies
          msg = 'The private companies removed from play are: '
          rejected = @companies.sort_by { rand }.take(12 - (@players.size * 2))
          rejected.sort_by { |c| @companies.index(c) }.each do |company|
            msg += "#{company.name}, "
            @companies.delete(company)
          end
          @log << msg.sub(/, $/, '.')
        end

        def setup_minors
          msg = 'The minor companies removed from play are: '
          minors = @corporations.select { |c| c.type == :minor }

          case @players.size
          when 2
            rejected = minors.sort_by { rand }.take(4)
          when 3
            rejected = minors.sort_by { rand }.take(2)
          end

          rejected.sort_by { |c| @corporations.index(c) }.each do |corp|
            hex = hex_by_id(corp.coordinates)
            hex.tile.cities[corp.city || 0].remove_tokens!
            hex.tile.cities[corp.city || 0].remove_reservation!(corp)
            msg += "#{corp.name}, "
            @corporations.delete(corp)
          end
          @log << msg.sub(/, $/, '.')
        end

        def setup_corps
          @corporations.each { |c| c.tokens.pop(c.tokens.size - major_token_count) if c.type == :major }
          return if @players.size == 4

          removed = @corporations.select { |c| c.type == :major }.min_by { rand }
          @corporations.delete(removed)
          @log << "#{removed.name} corporation is removed because there are fewer than 4 players"
        end

        def major_token_count
          @players.size == 4 ? 3 : 4
        end

        def fix_token_count!(corporation)
          corporation.tokens << Engine::Token.new(corporation, price: 40) while corporation.tokens.size < major_token_count
        end

        def unstarted_corporation_summary
          minor = @corporations.select { |c| c.type == :minor }
          major = @corporations.select { |c| c.type == :major }
          ["#{minor.size} minor, #{major.size} major", minor + major]
        end

        def calculate_interest
          # Number of loans interest is due on is set before taking loans in that OR
          @interest.clear
          @corporations.each { |c| calculate_corporation_interest(c) }
        end

        def num_trains(train)
          num_players = @players.size

          case train[:name]
          when '3'
            num_players == 2 ? 3 : num_players + 2
          when '4'
            num_players
          else
            train[:num]
          end
        end

        def event_three_trains_will_convert!
          @convert_3s = true
          @log << '--All remaining 3/2G trains in the supply will be replaced with 3+1/2G+1 trains at the end of the OR set--'
        end

        def forfeit_cash!(entity)
          old_price = entity.share_price
          entity.spend(entity.cash, bank) if entity.cash.positive?
          @stock_market.move_left(entity)
          log_share_price(entity, old_price)
        end

        def trainless_penalty(entity)
          old_price = entity.share_price

          @log << "#{entity.name} was unable to buy a train and is trainless. Its stock price will drop one space"
          @stock_market.move_left(entity)
          log_share_price(entity, old_price)
        end

        G_TRAINS = %w[1G 2G 2+1G 3+2G 4+2G 2+2GD].freeze
        PORT_HEXES = %w[F3 G4 G6 G8 H9 H17 H19].freeze
        MINE_HEXES = %w[B15 D7 D17 E2 E6].freeze
        MINE_ONLY_HEXES = %w[B15 D7 E2].freeze
        NORTH_HEXES = %w[A4 A8 F1].freeze
        SOUTH_HEXES = %w[C20 E20 F19].freeze
        NORTH_SOUTH_BONUS_HEX = 'I1'
        PORT_MINE_BONUS_HEX = 'I3'

        def g_train?(train)
          self.class::G_TRAINS.include?(train.name)
        end

        def add_mine_node(tile)
          mine = Part::Town.new('0', visit_cost: 0)
          mine.tile = tile
          mine.index = tile.nodes.size
          tile.nodes << mine
        end

        def mine_only_hex?(hex)
          self.class::MINE_ONLY_HEXES.include?(hex&.id)
        end

        def mine_node?(node)
          node.town? && mine_only_hex?(node.hex)
        end

        def mine_node_in(hex)
          hex.tile.nodes.find(&:town?) if mine_only_hex?(hex)
        end

        def init_graph
          G1812::Graph.new(self)
        end

        def update_tile_lists(tile, old_tile)
          super
          return unless mine_only_hex?(old_tile.hex)

          old_tile.nodes.reject!(&:town?)
          add_mine_node(tile)
        end

        def route_links(from, to, _corporation)
          mine, other = mine_node?(to) ? [to, from] : [from, to]
          return [] unless mine_node?(mine)

          found = mine_paths(other, mine.hex)
          (found + found.map { |paths| paths.reject { |p| p.hex == mine.hex } })
            .map { |paths| mine_chain([from, to], paths) }
        end

        def mine_paths(node, hex)
          found = []
          node.paths.each { |start| start.walk { |path, visited| found << visited.keys if path.hex == hex } }
          found
        end

        def mine_chain(nodes, paths)
          { nodes: nodes, paths: paths, hexes: paths.map(&:hex), id: paths.map { |p| p.hex.id } }
        end

        # Ports and mines never use up a train's count (rule 7.3.4); Durham and
        # Doncaster's mine is still scored when their small city is skipped.
        # Returns [free stops, small cities, large cities and off-boards].
        def counted_stops(route)
          free, counted = route.visited_stops.partition { |s| free_stop?(s) }
          [free, *counted.partition(&:town?)]
        end

        def free_stop?(stop)
          mine_node?(stop) || self.class::PORT_HEXES.include?(stop.hex.id)
        end

        def compute_stops(route)
          route.visited_stops.select { |s| free_stop?(s) } + Base.instance_method(:compute_stops).bind_call(self, route)
        end

        def revenue_stops(route)
          super.reject { |s| free_stop?(s) }
        end

        def route_distance_str(route)
          _, towns, cities = counted_stops(route)
          towns.empty? ? cities.size.to_s : "#{cities.size}+#{towns.size}"
        end

        def route_mines(route)
          route.all_hexes.map(&:id) & self.class::MINE_HEXES
        end

        def check_other(route)
          hexes = route.all_hexes
          port = hexes.map(&:id).intersect?(self.class::PORT_HEXES)
          mines = route.visited_stops.select { |s| mine_node?(s) }
          if g_train?(route.train)
            raise GameError, 'Goods trains must run to a port' unless port
            raise GameError, 'Goods trains must have a mine on the route' if route_mines(route).empty?
            raise GameError, 'Route must use the track in the mine hex' unless mines.all? { |m| hexes.include?(m.hex) }
          else
            raise GameError, 'Only goods trains can run to ports' if port
            raise GameError, 'Only goods trains can run to mines' unless mines.empty?
          end
        end

        def check_route_combination(routes)
          mine_sets = routes.select { |r| g_train?(r.train) }.map { |r| route_mines(r) }.reject(&:empty?)
          raise GameError, 'Each goods train must use a different mine' unless distinct_mines?(mine_sets)
        end

        def distinct_mines?(mine_sets, used = [])
          return true if mine_sets.empty?

          (mine_sets.first - used).any? { |mine| distinct_mines?(mine_sets.drop(1), used + [mine]) }
        end

        def revenue_for(route, stops)
          revenue = super
          train = route.train
          revenue += @north_south_bonus.route_revenue(@phase, train) if north_south?(stops)
          revenue += @port_mine_bonus.route_revenue(@phase, train) if g_train?(train) && route_mines(route).any?
          revenue
        end

        def north_south?(stops)
          ids = stops.map { |s| s.hex.id }
          ids.intersect?(self.class::NORTH_HEXES) && ids.intersect?(self.class::SOUTH_HEXES)
        end

        def remove_some_minors?
          @remove_some_minors ||= @optional_rules&.include?(:remove_some_minors)
        end
      end
    end
  end
end
