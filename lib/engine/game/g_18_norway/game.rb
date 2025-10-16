# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'companies'
require_relative 'corporations'
require_relative 'map'
require_relative 'trains'
require_relative 'phases'

module Engine
  module Game
    module G18Norway
      class Game < Game::Base
        attr_reader :ferry_graph, :jump_graph

        include_meta(G18Norway::Meta)
        include Companies
        include Corporations
        include Map
        include Trains
        include Phases

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '%skr'
        EBUY_SELL_MORE_THAN_NEEDED = false
        CAPITALIZATION = :incremental
        MUST_BUY_TRAIN = :always
        POOL_SHARE_DROP = :left_block
        SELL_AFTER = :p_any_operate
        SELL_MOVEMENT = :left_block
        HOME_TOKEN_TIMING = :float
        EBUY_PRES_SWAP = false
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        SOLD_OUT_INCREASE = true

        BANKRUPTCY_ENDS_GAME_AFTER = :one

        BANK_CASH = 999_000

        CLOSED_CORP_RESERVATIONS_REMOVED = false

        GAME_END_CHECK = { bankrupt: :immediate, six_train: :one_more_full_or_set }.freeze

        DEPOT_CLASS = G18Norway::Depot

        CERT_LIMIT = {
          3 => { 0 => 12, 1 => 12, 2 => 12, 3 => 15, 4 => 15, 5 => 17, 6 => 17, 7 => 19, 8 => 19 },
          4 => { 0 => 9, 1 => 9, 2 => 9, 3 => 11, 4 => 11, 5 => 13, 6 => 13, 7 => 15, 8 => 15 },
          5 => { 0 => 7, 1 => 7, 2 => 7, 3 => 9, 4 => 9, 5 => 10, 6 => 10, 7 => 12, 8 => 12 },
        }.freeze

        STARTING_CASH = { 3 => 400, 4 => 300, 5 => 240 }.freeze

        MARKET = [
          %w[0c 10f 20f 30f 40f
             50p 60p 70p 80p 90p 100p 112p 124p 137p 150p
             165Y 180Y 195Y 220Y 245Y 270Y 300Y 330Y 365Y 400Y 440Y 480Y],
           ].freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          pays_bonus_3: :white,
          only_president: :gray
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(
          pays_bonus_3: 'Triple jump if dividend ≥ 3X',
          only_president: 'Move left only when president sells'
        )

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'nr_one_or' => ['NR after first OR', 'Nationalization Round only after first Operating Round'],
          'nr_each_or' => ['NR after each OR', 'Nationalization Round after each Operating Round'],
        ).freeze

        ASSIGNMENT_TOKENS = {
          'MOUNTAIN_SMALL' => '/icons/hill.svg',
          'MOUNTAIN_BIG' => '/icons/mountain.svg',
        }.freeze

        EVENTS_TEXT = {
          'lm_green' => ['green_ferries', 'Mjøsa green ferry lines opens up.'],
          'lm_brown' => ['brown_ferries', 'Mjøsa brown ferry lines opens up.'],
        }.freeze

        def game_end_check_six_train?
          @end_game_triggered
        end

        def event_end_game!
          @log << '-- Event: End game --'
          @end_game_triggered = true
        end

        def hovedbanen
          @hovedbanen ||= corporation_by_id('H')
        end

        def hovedbanen?(corporation)
          hovedbanen == corporation
        end

        def nsb
          @nsb ||= corporation_by_id('NSB')
        end

        def harbor_city_coordinates(hex_id)
          CITY_HARBOR_MAP.key(hex_id)
        end

        def harbor_hex?(hex)
          HARBOR_HEXES.include?(hex.id)
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend < 1/2 stock price', '1 ←'],
            ['Dividend ≥ 1/2 stock price but < stock price', 'none'],
            ['Dividend ≥ stock price', '1 →'],
            ['Dividend ≥ 2X stock price', '2 →'],
            ['Dividend ≥ 3X stock price and stock price ≥ 165', '3 →'],
            ['Any number of shares sold', '1 ←'],
            ['Corporation has any shares in the Market at end of an SR', '1 ←'],
            ['Corporation is sold out at end of an SR', '1 →'],
          ]
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        MOUNTAIN_BIG_HEXES = %w[F21 H21 I22 G26 F27 F29 E30].freeze
        MOUNTAIN_SMALL_HEXES = %w[H19 F23 E26 E28 G28 H27 I28].freeze
        HARBOR_HEXES = %w[H13 A26 D15 A32 E36].freeze
        CITY_HARBOR_MAP = {
          'H17' => 'H13',
          'C26' => 'A26',
          'E18' => 'D15',
          'C32' => 'A32',
          'D35' => 'E36',
        }.freeze

        def switcher
          @switcher ||= corporation_by_id('Ø')
        end

        def switcher?(corporation)
          switcher == corporation
        end

        EXTRA_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        def setup
          setup_company_price_up_to_one_and_half_face

          %w[P2 P3 P4].each do |prefix|
            suffix = 'B'
            suffix = rand.even? ? 'A' : 'B' if @optional_rules.include?(:random_private_companies)
            suffix = 'A' if @optional_rules.include?(:private_b_companies)

            @companies.select { |c| c.id.start_with?(prefix + suffix) }.each do |company|
              company.close!
              @round.active_step.companies.delete(company)
            end
          end

          MOUNTAIN_BIG_HEXES.each { |hex| hex_by_id(hex).assign!('MOUNTAIN_BIG') }
          MOUNTAIN_SMALL_HEXES.each { |hex| hex_by_id(hex).assign!('MOUNTAIN_SMALL') }
          corporation_by_id('H').add_ability(Engine::Ability::Base.new(
            type: 'corrupt',
            description: 'May nationalize using 0, 1 or 2 shares',
          ))

          corporation_by_id('R').add_ability(Engine::Ability::Base.new(
            type: 'free_tunnel',
            description: 'May build tunnels for free'
          ))

          corporation_by_id('V').add_ability(Engine::Ability::Base.new(
            type: 'free_ship',
            description: 'Free S3 ship before phase 4',
          ))

          switcher.add_ability(Engine::Ability::Base.new(
            type: 'switcher',
            description: 'May pass one tokened out city',
          ))

          corporation_by_id('S').add_ability(Engine::Ability::Base.new(
            type: 'extra_tile_lay',
            description: 'May lay two yellow until Oslo is connected',
          ))

          corporation_by_id('J').add_ability(Engine::Ability::Base.new(
            type: 'mail_contract',
            description: 'Mail contract 10/20/30',
          ))

          corporation_by_id('B').add_ability(Engine::Ability::Base.new(
            type: 'ignore_mandatory_train',
            description: 'Not mandatory to own a train unil Phase 5',
          ))

          @corporations.each do |corporation|
            ability = Ability::Token.new(type: 'token', hexes: HARBOR_HEXES, extra_slot: true,
                                         from_owner: true, discount: 0, connected: true)
            corporation.add_ability(ability)
          end

          port = corporation_by_id('NSB')
          port.coordinates.each do |hex_id|
            token = Token.new(port, logo: '/icons/port.svg', simple_logo: '/icons/port.svg')
            city = hex_by_id(hex_id).tile.cities[0]
            city.place_token(port, token)
          end

          @all_tiles.each { |t| t.ignore_gauge_walk = true }
          @_tiles.values.each { |t| t.ignore_gauge_walk = true }
          @hexes.each { |h| h.tile.ignore_gauge_walk = true }
          update_cert_limit

          # Allow to build against Mjosa
          hex_by_id('I26').neighbors[1] = hex_by_id('H27')
          hex_by_id('I26').neighbors[5] = hex_by_id('J27')
          hex_by_id('H27').neighbors[4] = hex_by_id('I26')
          hex_by_id('J27').neighbors[2] = hex_by_id('I26')
        end

        def p4a
          @p4a ||= company_by_id('P4A')
        end

        def thunes_mekaniske
          @thunes_mekaniske ||= company_by_id('P2A')
        end

        def owns_thunes_mekaniske?(owner)
          thunes_mekaniske.owner == owner
        end

        def hvite_svan
          @hvite_svan ||= company_by_id('P2B')
        end

        def owns_hvite_svan?(owner)
          hvite_svan.owner == owner
        end

        def big_mountain?(hex)
          hex.assignments.include?('MOUNTAIN_BIG')
        end

        def small_mountain?(hex)
          hex.assignments.include?('MOUNTAIN_SMALL')
        end

        def mountain?(hex)
          big_mountain?(hex) || small_mountain?(hex)
        end

        def mjosa
          @mjosa ||= hex_by_id('I26')
        end

        def route_cost(route)
          cost = 0
          mult = 2
          mult = 1 if @phase.tiles.include?(:green)
          mult = 0 if @phase.tiles.include?(:brown)
          cost += 5 * mult if !owns_hvite_svan?(route.train.owner) && route.all_hexes.include?(mjosa)

          # P2 Thunes mekaniske verksted do not need to pay maintainance
          return cost if owns_thunes_mekaniske?(route.train.owner)

          cost + (route.all_hexes.count { |hex| mountain?(hex) } * 10)
        end

        def check_other(route)
          track_types = route.chains.flat_map { |connections| connections[:paths] }.flat_map(&:track).uniq

          raise GameError, 'Ships cannot run on land' if ship?(route.train) && track_types != [route.train.track_type]
          raise GameError, 'Trains cannot run on water' if !ship?(route.train) && track_types.include?(:narrow)

          cost = route_cost(route)
          raise GameError, 'Cannot afford the fees for this route' if route.train.owner.cash < cost
        end

        def revenue_str(route)
          stop_hexes = route.stops.map(&:hex)
          str = route.hexes.map { |h| stop_hexes.include?(h) ? h&.name : "(#{h&.name})" }.join('-')
          cost = route_cost(route)
          str += " -Fee(#{cost})" if cost.positive?
          str
        end

        def routes_revenue(routes)
          revenue = super(routes)
          return 0 if revenue.zero?
          return revenue if routes.empty?
          return revenue unless abilities(routes.first.train.owner, :mail_contract)

          revenue += 10 if @phase.tiles.include?(:yellow)
          revenue += 10 if @phase.tiles.include?(:green)
          revenue += 10 if @phase.tiles.include?(:brown)
          revenue
        end

        def stock_round
          G18Norway::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18Norway::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            G18Norway::Step::IssueShares,
            Engine::Step::HomeToken,
            G18Norway::Step::Track,
            G18Norway::Step::BuildTunnel,
            G18Norway::Step::Token,
            G18Norway::Step::Route,
            G18Norway::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Norway::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def ship?(train)
          train.track_type == :narrow
        end

        def cheapest_train
          depot_trains = depot.depot_trains.reject { |train| ship?(train) }
          depot_trains.min_by(&:price)
        end

        def cheapest_train_price(corporation)
          ability = abilities(corporation, :train_discount, time: 'buying_train')
          cheapest_train.min_price(ability: ability)
        end

        def can_go_bankrupt?(player, corporation)
          total_emr_buying_power(player, corporation) < cheapest_train_price(corporation)
        end

        def new_nationalization_round(round_num)
          G18Norway::Round::Nationalization.new(self, [
              G18Norway::Step::NationalizeCorporation,
              ], round_num: round_num)
        end

        def nationalize_corporation(entity, number_of_shares)
          value = convert(entity, number_of_shares)
          @log << "#{entity.name} nationalized and receives #{format_currency(value)}"
          update_cert_limit
        end

        def float_corporation(corporation)
          nationalize_corporation(corporation, 1) if game_end_check_six_train?
        end

        def next_round!
          @round =
            case @round
            when G18Norway::Round::Nationalization
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                if @phase.status.include?('nr_each_or') || @phase.status.include?('nr_one_or')
                  new_nationalization_round(@round.round_num)
                else
                  new_operating_round(@round.round_num + 1)
                end
              elsif @phase.status.include?('nr_each_or')
                or_round_finished
                new_nationalization_round(@round.round_num)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def payout_companies(ignore: [])
          return if @round.is_a?(G18Norway::Round::Nationalization)

          super(ignore: @phase.name.to_i == 2 ? ignore + ['P3B'] : ignore)
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def nationalized?(entity)
          entity.type == :nationalized
        end

        def convert(corporation, number_of_shares)
          shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear

          shares.each { |share| share.percent /= 2 }
          new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }

          shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          new_shares.each do |share|
            add_new_share(share)
          end
          corporation.type = :nationalized

          return 0 if number_of_shares.zero?

          bundle = ShareBundle.new(new_shares.take(number_of_shares))
          @bank.spend(bundle.price, corporation)
          share_pool.buy_shares(nsb, bundle, exchange: :free)

          bundle.price
        end

        def can_par?(corporation, _parrer)
          nsb != corporation
        end

        def tile_lays(entity)
          return EXTRA_TILE_LAYS if abilities(entity, :extra_tile_lay)

          super
        end

        def oslo
          @oslo ||= hex_by_id('H29')
        end

        def init_graph
          @ferry_graph = Graph.new(self, skip_track: :broad)
          @jump_graph = Graph.new(self, no_blocking: true)
          Graph.new(self, skip_track: :narrow)
        end

        def clear_graph
          @graph.clear
          @ferry_graph.clear
        end

        def clear_graph_for_entity(_entity)
          clear_graph
        end

        def can_run_route?(entity)
          return true if graph_for_entity(entity).route_info(entity)&.dig(:route_available)

          ferry_graph.route_info(entity)&.dig(:route_available)
        end

        def token_graph_for_entity(_entity)
          @graph
        end

        def harbor_token?(city, corporation)
          harbor_id = CITY_HARBOR_MAP[city.hex.id]
          return false if harbor_id.nil?

          harbor = hex_by_id(harbor_id)
          return true if harbor.tile.cities[0].extra_tokens.find { |t| t.corporation == corporation }

          false
        end

        def for_graph_city_tokened_by?(city, entity, graph)
          return city_tokened_by?(city, entity) if graph == @graph

          harbor_token?(city, entity)
        end

        def connected?(a, b, corporation, train)
          return true if a.connects_to?(b, corporation)

          [a.a, a.b].each do |part|
            next unless b.nodes.include?(part)
            next unless part.city?
            return harbor_token?(part, corporation) if ship?(train)
          end
          false
        end

        def check_connected(route, corporation)
          return if route.ordered_paths.each_cons(2).all? { |a, b| connected?(a, b, corporation, route.train) }

          return super unless @round.train_upgrade_assignments[route.train]

          visits = route.visited_stops

          blocked = nil

          if visits.size > 2
            visits[1..-2].each do |node|
              next if !node.city? || !node.blocks?(corporation)
              raise GameError, 'Route can only bypass one tokened-out city' if blocked

              blocked = node
            end
          end
          super(route, nil)
        end

        def check_route_token(route, token)
          return if token

          visited = route.visited_stops
          token = if ship?(route.train)
                    visited.find { |stop| harbor_token?(stop, route.corporation) || stop.tokened_by?(route.corporation) }
                  else
                    visited.find { |stop| stop.tokened_by?(route.corporation) }
                  end

          raise NoToken, 'Route must contain token' unless token
        end

        def update_cert_limit_to(new_cert_limit)
          @cert_limit = new_cert_limit
          @log << "Certificate limit is now #{@cert_limit}"
        end

        def update_cert_limit
          nr = @corporations.count { |c| nationalized?(c) }
          new_cert_limit = CERT_LIMIT[@players.size][nr]
          update_cert_limit_to(new_cert_limit) unless @cert_limit == new_cert_limit
        end

        def after_buy_company(player, company, price)
          return super if company.id != 'P7'

          h = hovedbanen
          share_price = @stock_market.par_prices.find { |pp| pp.price * 2 <= price }
          @stock_market.set_par(h, share_price)
          @bank.spend(price, h)
          abilities(company, :shares) do |ability|
            ability.shares.each do |share|
              share_pool.buy_shares(player, share, exchange: :free)
            end
          end
        end

        def close_corporation(corporation, quiet: false)
          super
          @corporations << reset_corporation(corporation)
        end

        def event_lm_green!
          @log << '-- Event: Mjøsa green ferry lines opens up. --'
          mjosa.lay(tile_by_id('LM1-0'))
        end

        def event_lm_brown!
          @log << '-- Event: Mjøsa brown ferry lines opens up. --'
          mjosa.lay(tile_by_id('LM2-0'))
        end

        def compute_stops(route)
          stops = super
          if @round.train_upgrade_assignments[route.train]
            skipped = skipped_stop(route, stops)
            stops.reject! { |stop| stop == skipped } if skipped
          end
          stops
        end

        def tokened_out_stop(corporation, stops)
          stops[1..-2].find { |node| node.city? && node.blocks?(corporation) }
        end

        def skipped_stop(route, stops)
          return nil if stops.size <= 2

          # Blocked stop is highest priority as it may stop route from being legal
          corporation = route.train.owner
          t = tokened_out_stop(corporation, stops)
          return t if t

          counted_stops = stops.select { |stop| stop&.visit_cost&.positive? }

          # Skipping is optional - if we are using STRICTLY fewer stops than distance (jumping adds 1) we don't need to skip
          return nil if counted_stops.size < route.train.distance

          # Count how many of our tokens are on the route; if only one we cannot skip that one.
          tokened_stops = counted_stops.select { |stop| stop.tokened_by?(route.train.owner) }
          counted_stops.delete(tokened_stops.first) if tokened_stops.one?

          # Find the lowest revenue stop that can be skipped
          counted_stops.min_by { |stop| revenue_for(route, stops.reject { |s| s == stop }) }
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G18Norway::Step::IssueShares) }.active?

          num_shares = entity.num_player_shares - entity.num_market_shares
          bundles = bundles_for_corporation(entity, entity)
          share_price = stock_market.find_share_price(entity, :left).price

          bundles
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.num_shares > num_shares }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G18Norway::Step::IssueShares) }.active?

          share_price = stock_market.find_share_price(entity, :right).price

          bundles_for_corporation(share_pool, entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def emergency_issuable_bundles(corp)
          return [] unless corp.trains.empty?

          available = @depot.available_upcoming_trains.reject { |train| ship?(train) }
          return [] unless (train = available.min_by(&:price))
          return [] if corp.cash >= cheapest_train_price(corp)

          bundles = bundles_for_corporation(corp, corp)

          num_issuable_shares = corp.num_player_shares - corp.num_market_shares
          bundles.reject! { |bundle| bundle.num_shares > num_issuable_shares }

          bundles.each do |bundle|
            directions = [:left] * (1 + bundle.num_shares)
            bundle.share_price = stock_market.find_share_price(corp, directions).price
          end

          bundles.reject! { |b| b.price.zero? }

          bundles.sort_by!(&:price)

          train_buying_bundles = bundles.select { |b| (corp.cash + b.price) >= train.price }
          unless train_buying_bundles.empty?
            bundles = train_buying_bundles

            index = bundles.find_index { |b| (corp.cash + b.price) >= train.price }
            return bundles.take(index + 1) if index

            return bundles
          end

          biggest_bundle = bundles.max_by(&:num_shares)
          return [biggest_bundle] if biggest_bundle

          []
        end

        def sell_movement(corporation = nil)
          return self.class::SELL_MOVEMENT unless corporation
          return :left_block_pres if corporation.second_share.price <= 40

          self.class::SELL_MOVEMENT
        end

        def setup_company_price_up_to_one_and_half_face
          @companies.each do |company|
            company.min_price = (company.value * 0.5)
            company.max_price = (company.value * 1.5)
          end
        end

        def check_sale_timing(entity, bundle)
          return false if @turn <= 1 && !@round.operating?

          super(entity, bundle)
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          corporation = bundle.corporation

          # Check if selling would make NSB president
          if bundle.shares.any?(&:president) &&
             corporation.share_holders[nsb] >= bundle.presidents_share.percent &&
             corporation.player_share_holders.reject do |p, _|
               p == bundle.owner || p == nsb
             end.values.max.to_i < bundle.presidents_share.percent
            raise GameError, 'Cannot sell shares as NSB would become president'
          end

          super
        end

        def after_phase_change(name)
          super
          # Only proceed if we're in phase 5
          return unless name.to_i == 5

          # Find P3B company and get its owner
          p4b_company = @companies.find { |c| c.id == 'P4B' }
          return unless p4b_company&.owner&.corporation?

          corporation = p4b_company.owner

          # Get L1 hex (which is currently an offboard hex)
          l1_hex = hex_by_id('L1')
          return unless l1_hex

          # Create a new city tile to replace the offboard tile
          new_tile = Tile.from_code(
            'BODØ',
            'red',
            'city=revenue:green_0|brown_180,slots:1;path=a:0,b:_0',
            reservation_blocks: self.class::TILE_RESERVATION_BLOCKS_OTHERS,
            unlimited: false,
            hidden: false
          )
          return unless new_tile

          # Replace the tile on the hex
          l1_hex.lay(new_tile)

          # Create a new token for the corporation
          token = Token.new(corporation)
          corporation.tokens << token

          # Place the token in the city (first city on the tile)
          city = l1_hex.tile.cities.first
          city.place_token(corporation, token, free: true, extra_slot: false)
          @graph.clear
          @log << "#{corporation.name} places a token in #{l1_hex.name} due to P4B ownership"
        end
      end
    end
  end
end
