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
        EBUY_SELL_MORE_THAN_NEEDED = true
        CAPITALIZATION = :incremental
        MUST_BUY_TRAIN = :always
        POOL_SHARE_DROP = :left_block
        SELL_AFTER = :p_any_operate
        SELL_MOVEMENT = :left_block
        HOME_TOKEN_TIMING = :float

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true

        BANKRUPTCY_ENDS_GAME_AFTER = :one

        BANK_CASH = 999_000

        GAME_END_CHECK = { bankrupt: :immediate, custom: :one_more_full_or_set }.freeze

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

        ASSIGNMENT_TOKENS = {
          'MOUNTAIN_SMALL' => '/icons/hill.svg',
          'MOUNTAIN_BIG' => '/icons/mountain.svg',
        }.freeze

        EVENTS_TEXT = {
          'lm_green' => ['green_ferries', 'Mjøsa green ferry lines opens up.'],
          'lm_brown' => ['brown_ferries', 'Mjøsa brown ferry lines opens up.'],
        }.freeze

        def custom_end_game_reached?
          @custom_end_game
        end

        def event_custom_end_game!
          @log << '-- Event: End game --'
          @custom_end_game = true
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

        MOUNTAIN_BIG_HEXES = %w[E21 G21 H22 F26 E27 E29 D30].freeze
        MOUNTAIN_SMALL_HEXES = %w[G19 E23 D26 D28 F28 G27 H28].freeze
        HARBOR_HEXES = %w[G15 A25 C17 A31 B36].freeze
        CITY_HARBOR_MAP = {
          'G17' => 'G15',
          'B26' => 'A25',
          'D18' => 'C17',
          'B32' => 'A31',
          'C35' => 'B36',
        }.freeze

        def switcher
          @switcher ||= corporation_by_id('Ø')
        end

        def switcher?(corporation)
          switcher == corporation
        end

        EXTRA_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        def setup
          MOUNTAIN_BIG_HEXES.each { |hex| hex_by_id(hex).assign!('MOUNTAIN_BIG') }
          MOUNTAIN_SMALL_HEXES.each { |hex| hex_by_id(hex).assign!('MOUNTAIN_SMALL') }
          corporation_by_id('H').add_ability(Engine::Ability::Base.new(
            type: 'corrupt',
            description: 'May nationalize using 0, 1 or 2 shares',
          ))

          corporation_by_id('R').add_ability(Engine::Ability::Base.new(
            type: 'free_tunnel',
            description: 'Free tunnel'
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
            description: 'May lay two yellow',
          ))

          corporation_by_id('J').add_ability(Engine::Ability::Base.new(
            type: 'mail_contract',
            description: 'Mail contract 10/20/30',
          ))

          corporation_by_id('B').add_ability(Engine::Ability::Base.new(
            type: 'ignore_mandatory_train',
            description: 'Not mandatory to own a train',
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

          # Allow to build against Mjosa
          hex_by_id('H26').neighbors[1] = hex_by_id('G27')
          hex_by_id('H26').neighbors[5] = hex_by_id('I27')
          hex_by_id('G27').neighbors[4] = hex_by_id('H26')
          hex_by_id('I27').neighbors[2] = hex_by_id('H26')
        end

        def p4
          @p4 ||= company_by_id('P4')
        end

        def thunes_mekaniske
          @thunes_mekaniske ||= company_by_id('P2')
        end

        def owns_thunes_mekaniske?(owner)
          thunes_mekaniske.owner == owner
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
          @mjosa ||= hex_by_id('H26')
        end

        def route_cost(route)
          cost = 0
          mult = 2
          mult = 1 if @phase.tiles.include?(:green)
          mult = 0 if @phase.tiles.include?(:brown)
          cost += 5 * mult if route.all_hexes.include?(mjosa)

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

        def cheapest_train_price
          depot_trains = depot.depot_trains.reject { |train| ship?(train) }
          train = depot_trains.min_by(&:price)
          train.price
        end

        def can_go_bankrupt?(player, corporation)
          total_emr_buying_power(player, corporation) < cheapest_train_price
        end

        def new_nationalization_round(round_num)
          G18Norway::Round::Nationalization.new(self, [
              G18Norway::Step::NationalizeCorporation,
              ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when G18Norway::Round::Nationalization
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
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
                new_nationalization_round(@round.round_num)
              else
                @turn += 1
                or_round_finished
                if @phase.tiles.include?(:green)
                  new_nationalization_round(@round.round_num)
                else
                  or_set_finished
                  new_stock_round
                end
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
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
          @oslo ||= hex_by_id('G29')
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

        def connected?(a, b, corporation)
          return true if a.connects_to?(b, corporation)

          [a.a, a.b].each do |part|
            next unless b.nodes.include?(part)
            next unless part.city?

            return harbor_token?(part, corporation)
          end
          false
        end

        def check_connected(route, corporation)
          return if route.ordered_paths.each_cons(2).all? { |a, b| connected?(a, b, corporation) }

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
          token = visited.find { |stop| harbor_token?(stop, route.corporation) }

          raise NoToken, 'Route must contain token' unless token
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

        def event_lm_green!
          @log << '-- Event: Mjøsa green ferry lines opens up. --'
          mjosa.lay(tile_by_id('LM1-0'))
        end

        def event_lm_brown!
          @log << '-- Event: Mjøsa brown ferry lines opens up. --'
          mjosa.lay(tile_by_id('LM2-0'))
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
          return [] if corp.cash >= train.price

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
      end
    end
  end
end
