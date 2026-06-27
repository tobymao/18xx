# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
require_relative '../double_sided_tiles'
require_relative 'trains'
require_relative 'sugar'

module Engine
  module Game
    module G18Cuba
      class Game < Game::Base
        include_meta(G18Cuba::Meta)
        include Entities
        include Map
        include Trains
        include Sugar

        include DoubleSidedTiles

        TRACK_RESTRICTION = :permissive
        CURRENCY_FORMAT_STR = '$%s'
        HOME_TOKEN_TIMING = :operate

        EBUY_FROM_OTHERS = :never
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true

        DEPOT_CLASS = G18Cuba::Depot

        BANK_CASH = 10_000

        CERT_LIMIT = { 2 => 35, 3 => 30, 4 => 20, 5 => 17, 6 => 15 }.freeze

        STARTING_CASH = { 2 => 950, 3 => 900, 4 => 680, 5 => 650, 6 => 650 }.freeze

        MARKET = [
          %w[50 55 60 65 70p 75p 80p 85p 90p 95p 100p 105 110 115 120 126 192 198 144
             151 158 172 180 188 196 204 013 222 231 240 250 260 275 290 300],
        ].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Buy trains', 'Can buy trains from other corporations'],
        ).freeze

        PHASES = [{ name: '2', train_limit: { minor: 2, major: 4 }, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: { minor: 2, major: 4 },
                    tiles: %i[yellow green],
                    status: ['can_buy_trains'],
                    operating_rounds: 2,
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: { minor: 2, major: 3 },
                    tiles: %i[yellow green],
                    status: ['can_buy_trains'],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: { minor: 2, major: 2 },
                    tiles: %i[yellow green brown],
                    status: ['can_buy_trains'],
                    operating_rounds: 3,
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: { minor: 2, major: 2 },
                    tiles: %i[yellow green brown],
                    status: ['can_buy_trains'],
                    operating_rounds: 3,
                  },
                  {
                    name: '8+',
                    on: '8+',
                    train_limit: { minor: 2, major: 2 },
                    tiles: %i[yellow green brown gray],
                    status: ['can_buy_trains'],
                    operating_rounds: 3,
                  }].freeze

        def operating_order
          # Minors operate before majors per game rules.
          floated = @corporations.select(&:floated?)
          minors, majors = floated.partition { |c| c.type == :minor }
          minors.sort_by { |c| minor_operating_sort_key(c) } + majors.sort
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            G18Cuba::Step::Track,
            Engine::Step::Token,
            G18Cuba::Step::Route,
            G18Cuba::Step::Dividend,
            G18Cuba::Step::DiscardTrain,
            G18Cuba::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: :flip)
        end

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end

        def num_trains(train)
          num_players = [@players.size, 2].max
          TRAIN_FOR_PLAYER_COUNT[num_players][train[:name].to_sym]
        end

        def company_header(company)
          case company.type
          when :concession
            'CONCESSION'
          when :commission
            'COMMISSIONER'
          else
            raise "Unknown company type: #{company.type}"
          end
        end

        def commissioners
          @commissioners ||= @companies.select { |c| c.type == :commission }
        end

        def concessions
          @concessions ||= @companies.select { |c| c.type == :concession }
        end

        def skip_route_track_type(train)
          # Wagons cannot run routes independently; only regular trains enforce track type.
          return if wagon?(train)

          opposite_gauge(train.track_type)
        end

        def check_other(route)
          # A cube-carrying wagon train must run to a harbor, and only load mills on its route (rule VII.10).
          if train_with_cubes?(route.train)
            raise GameError, 'A wagon carrying sugar cubes must run to a harbor' if route.visited_stops.none? { |s| harbor?(s) }

            mills = mill_corps_on_route(route)
            raise GameError, 'Sugar mill is not on the route' unless cubes_on_train(route.train).all? { |c| mills.include?(c) }
          end

          # Regular trains cannot cross to the opposite gauge.
          return if wagon?(route.train)

          track_type = route.train.track_type
          wrong_track = opposite_gauge(track_type)
          return if route.chains.none? { |c| c[:paths].any? { |p| p.track == wrong_track } }

          raise GameError, "#{track_type.to_s.capitalize} gauge train cannot run on #{wrong_track} gauge track"
        end

        def route_trains(entity)
          # Wagons are not runnable trains; they attach to trains rather than running independently.
          super.reject { |t| wagon?(t) }
        end

        def crowded_corps
          # TODO: FC logic - train limit
          @crowded_corps ||= corporations.select { |c| train_limit_overflow(c).value?(true) }
        end

        # A corp owning only wagons is still trainless (wagons don't count as trains).
        def trainless?(corporation)
          num_corp_trains(corporation).zero?
        end

        def must_buy_train?(entity)
          # Require a buy only when a gauge-matching non-wagon train exists in the depot — else nothing is legally buyable.
          trainless?(entity) &&
            depot.depot_trains.any? { |t| !wagon?(t) && t.track_type == gauge_for(entity) }
        end

        # Per rule VII.12: cross-company train purchases unlock once the first 3/3+ train is sold (phase 3+).
        def can_buy_train_from_others?
          @phase.status.include?('can_buy_trains')
        end

        def setup
          super
          @tile_groups = init_tile_groups
          initialize_tile_opposites!
          @unused_tiles = []
          sugar_setup
          @minor_graph = Graph.new(self, skip_track: :broad)
        end

        def init_graph
          Graph.new(self, skip_track: :narrow)
        end

        def graph_for_entity(entity)
          return @graph unless entity&.type == :minor

          @minor_graph ||= Graph.new(self, skip_track: :broad)
        end

        def clear_graph
          @minor_graph.clear
          super
        end

        def clear_graph_for_entity(entity)
          if entity&.type == :minor
            @minor_graph.clear
          else
            super
          end
        end

        def init_tile_groups
          self.class::TILE_GROUPS
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [G18Cuba::Step::SelectionAuction])
        end

        def new_draft_round
          Engine::Round::Draft.new(self, [G18Cuba::Step::SimpleDraft], reverse_order: false)
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::HomeToken,
            G18Cuba::Step::BuySellParShares,
          ])
        end

        def close_unopened_minors
          @corporations.each { |c| c.close! if c.type == :minor && !c.floated? }
          @log << 'Unopened minors close'
        end

        def can_par?(corporation, entity)
          # FC cannot be parred
          # Minors can only be parred by players with a concession to exchange
          return false if corporation.type == :state
          return super unless corporation.type == :minor

          entity.companies.any? { |c| abilities(c, :exchange) }
        end

        def next_round!
          # After Init -> Auction Commissions -> Draft Concessions -> Stock Round -> Operating Rounds
          @round =
            case @round
            when Round::Draft
              new_stock_round
            when Round::Stock
              close_unopened_minors if @turn == 1
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
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players(:least_cash, log_player_order: true)
              new_draft_round
            end
        end

        def home_token_locations(corporation)
          # TODO: FEC home token, especifically corner case to be added with no available token -> use cheater token
          return super unless corporation.type == :minor

          hexes.select do |hex|
            # no token allowed on Y and H cities
            next false if hex.tile.labels.any? { |l| %w[Y H].include?(l.to_s) }

            hex.tile.cities.any? do |city|
              next false unless city.tokenable?(corporation, free: true)

              # no other minor may already be here
              city.tokens.none? { |t| t&.corporation&.type == :minor }
            end
          end
        end

        def token_cost_override(entity, city, token)
          return 0 if (entity.type == :minor || entity.sym == 'FEC') && (token == entity.tokens.first)

          super
        end

        def revenue_for(route, stops)
          revenue = super
          revenue -= extended_harbor_revenue(route, stops)
          revenue + wagon_cube_bonus(route)
        end

        def revenue_str(route)
          bonus = wagon_cube_bonus(route)
          return super if bonus.zero?

          # Append the wagon's sugar-cube delivery value, which is not part of the base route revenue.
          "#{super} + #{format_currency(bonus)} (wagon)"
        end

        def check_distance(route, visits, train = nil)
          # Record the live route per train so the Route step can offer cube loading (like 18Uruguay).
          @round.current_routes[route.train.id] = route
          # A wagon may extend a route by exactly one extra stop, only to a harbor (rule VII.10).
          train ||= route.train
          return super unless @round.wagon_for_train.key?(train.id)
          return super unless train_with_cubes?(train)
          return super unless train.distance.is_a?(Numeric)

          total = visits.sum(&:visit_cost)
          return super if total <= train.distance

          raise RouteTooLong, 'Wagon harbor extension requires a harbor at the route end' unless visits.any? { |s| harbor?(s) }
          raise RouteTooLong, 'Wagon may only extend a route by one harbor stop' if total > train.distance + 1
        end

        def or_round_finished
          # For the moment reset sugar cubes, handling for FC to be implemented later
          reset_cubes_on_train!
          return if @sugar_cubes.values.none?(&:positive?)

          @sugar_cubes.each { |corp, cubes| update_sugar_cube_icons(corp, 0) if cubes.positive? }
          @sugar_cubes.clear
          @log << 'All remaining sugar cubes are removed at the end of the Operating Round.'
        end

        def check_route_combination(routes)
          # Each delivering wagon train must deliver to a different harbor (rule VII.10).
          # Filter on delivering, not merely attached: empty wagons don't compete for a harbor delivery.
          super
          delivering_routes = routes.select { |r| train_with_cubes?(r.train) }
          return if delivering_routes.size <= 1

          harbors = delivering_routes.map { |r| r.visited_stops.find { |s| harbor?(s) }&.hex }.compact
          raise GameError, 'Each wagon train must run to a different harbor' if harbors.uniq.size != harbors.size
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          corp = selected_company || @round&.current_entity&.corporation

          super.reject do |t|
            # Hex not available for selector, therefore passing nil and ignoring home hex check for minors
            tile_blocked_for_corp?(t, corp, nil, for_selector: true)
          end
        end

        def upgrades_to_correct_city_town?(from, to)
          return true if sugar_cane_tile?(from) && sugar_cane_open_for_majors? && to.city_towns.empty?

          super
        end

        def upgrade_cost(tile, hex, entity, spender)
          # Minors lay on sugar cane hexes at no cost
          return 0 if entity&.type == :minor && sugar_cane_hex?(hex)

          super
        end

        def tile_blocked_for_corp?(tile, corp, hex, for_selector: false)
          return false unless corp

          if corp.type == :minor
            minor_tile_blocked?(tile, corp.tokens.first.hex, hex, for_selector: for_selector)
          else
            major_tile_blocked?(tile, hex, for_selector: for_selector)
          end
        end

        private

        def minor_operating_sort_key(corp)
          # Order by share price, then market position, then name.
          sp = corp.share_price
          [sp&.price || 0, sp&.corporations&.index(corp) || 0, corp.name]
        end

        def tile_has_only_track_type?(tile, track_type)
          tile.paths.all? { |path| path.track == track_type }
        end

        def mixed_gauge_city_tile?(tile)
          tile && !tile.cities.empty? && tile.paths.any? { |p| p.track == :narrow }
        end

        def minor_tile_blocked?(tile, home_hex, current_hex, for_selector: false)
          # Determines if a tile is illegal for a minor:
          # - Tiles with only broad tracks are always illegal
          # - City tiles are illegal except on the minor's home hex
          # - On sugar cane hexes, only tiles with hidden towns are legal (no plain track)
          # - When `for_selector` is true, the rules which require current_hex is ignored because the hex is unknown
          pure_broad = tile_has_only_track_type?(tile, :broad)

          return pure_broad if for_selector
          return pure_broad if current_hex == home_hex
          return true if sugar_cane_hex?(current_hex) && tile.towns.empty?

          !tile.cities.empty? || pure_broad
        end

        def major_tile_blocked?(tile, hex = nil, for_selector: false)
          # Pure narrow tiles cannot be part of a major's route
          return true if tile_has_only_track_type?(tile, :narrow)

          # Mixed gauge city tiles (sugar mill) are minor-only in yellow.
          # In green/brown they are only allowed as upgrades from an existing sugar mill
          # (e.g. L53 → L67, L67 → brown sugar mill); majors cannot place them on plain hexes.
          if mixed_gauge_city_tile?(tile)
            return true if tile.color == :yellow
            return false if for_selector
            return true unless mixed_gauge_city_tile?(hex&.tile)
          end

          # Yellow tiles must be pure broad for majors
          tile.color == :yellow && !tile_has_only_track_type?(tile, :broad)
        end
      end
    end
  end
end
