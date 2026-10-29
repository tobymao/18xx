# frozen_string_literal: true

require_relative '../g_1846/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../company_price_up_to_face'
require_relative '../base'
require_relative 'graph'

module Engine
  module Game
    module G1833NE
      class Game < Game::Base
        include_meta(G1833NE::Meta)
        include Entities
        include Map
        include CompanyPriceUpToFace

        attr_accessor :last_action, :lowell_merchants_company_activated

        BANK_CASH = 10_000
        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 400 }.freeze

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :float
        MUST_SELL_IN_BLOCKS = true
        POOL_SHARE_DROP = :left_block
        SELL_AFTER = :p_any_operate
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block_pres

        EBUY_FROM_OTHERS = :never
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        MUST_BUY_TRAIN = :always
        TILE_COST = 20

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        GAME_END_CHECK = {
          bankrupt: :immediate,
          bank: :full_or,
          all_closed: :immediate,
          final_train: :one_more_full_or_set,
        }.freeze

        CERT_LIMIT = {
          3 => { 14 => 35, 13 => 33, 12 => 30, 11 => 28, 10 => 26, 9 => 24, 8 => 22, 7 => 19, 6 => 16, 5 => 14 },
          4 => { 14 => 26, 13 => 25, 12 => 23, 11 => 21, 10 => 20, 9 => 18, 8 => 16, 7 => 14, 6 => 12, 5 => 10 },
          5 => { 14 => 21, 13 => 20, 12 => 18, 11 => 17, 10 => 16, 9 => 14, 8 => 13, 7 => 11, 6 => 10, 5 => 8 },
        }.freeze

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

        MARKET = [
          %w[0c 10 20 30 40p 50p 60p 70p 80p 90p 100p 112p 124p 137p 150p
             165 180 195 212 230 250 270 295 320 345 375 405 440 475 510 550 590 630 680 730],
           ].freeze

        PHASES = [
          {
            name: 'I',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: 'II',
            train_limit: 3,
            on: '3/5',
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: 'III',
            on: '4/7',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: 'IV',
            on: '6/9',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: 'V',
            on: '7+3',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 75,
            num: 8,
            obsolete_on: '3+3',
            rusts_on: '5+3',
            variants: [
              {
                name: '2+1',
                distance: [{ 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                           { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
                price: 100,
              },
            ],
          },
          {
            name: '3/5',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 5 }],
            price: 180,
            num: 5,
            obsolete_on: '6/9',
            rusts_on: '7+3',
            variants: [
              {
                name: '2+2',
                distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
                price: 140,
              },
            ],
          },
          {
            name: '4/7',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 7 }],
            price: 320,
            num: 6,
            obsolete_on: '7+3',
            variants: [
              {
                name: '3+3',
                distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
                price: 230,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6/9',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 9 }],
            price: 750,
            num: 3,
            variants: [
              {
                name: '5+3',
                distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 }],
                price: 640,
              },
            ],
            events: [
              { 'type' => 'remove_bonuses' },
              { 'type' => 'remove_reservations' },
            ],
          },
          {
            name: '7+3',
            distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => %w[city offboard town], 'pay' => 7, 'visit' => 7 }],
            price: 950,
            num: 15,
          },
        ].freeze

        INTERCONNECTION_EXTENSION = [
          { 'nodes' => %w[city offboard town], 'pay' => 0, 'visit' => 99, 'extension' => true },
        ].freeze

        def init_train_handler
          trains = game_trains.flat_map do |train|
            train = with_extension(train)
            Array.new(num_trains(train)) do |index|
              self.class::TRAIN_CLASS.new(**train, index: index)
            end
          end

          self.class::DEPOT_CLASS.new(trains, self)
        end

        def with_extension(train)
          train = train.merge(distance: extended_distance(train[:distance])) if train[:distance]
          return train unless train[:variants]

          train.merge(
            variants: train[:variants].map do |variant|
              variant.merge(distance: extended_distance(variant[:distance]))
            end
          )
        end

        def num_trains(train)
          return takeover_game? ? 5 : 3 if train[:name] == '6/9'

          train[:num]
        end

        def setup
          setup_company_price_up_to_face

          @last_action = nil
          @lowell_merchants_company_activated = false
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1833NE::Step::WaterfallAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Assign,
            G1846::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          G1833NE::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            Engine::Step::Assign,
            Engine::Step::SpecialToken,
            G1833NE::Step::SpecialTrack,
            G1833NE::Step::BuyCompany,
            G1846::Step::IssueShares,
            G1833NE::Step::TrackAndToken,
            G1833NE::Step::Route,
            G1846::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1833NE::Step::BuyTrain,
            [G1833NE::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def takeover_round
          G1833NE::Round::Takeover.new(self, [
            G1833NE::Step::ViewAcquirable,
            G1833NE::Step::TakeoverCorporation,
          ])
        end

        def extension_graph
          @extension_graph ||= G1833NE::Graph.new(self)
        end

        def autorouter_graph(_entity)
          extension_graph
        end

        def clear_graph_for_entity(entity)
          super
          @extension_graph&.clear
        end

        def for_graph_city_tokened_by?(city, corporation, graph)
          return true if graph.is_a?(G1833NE::Graph) && city.blocks?(corporation)

          super
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              remove_lowell_merchants_ability! if @lowell_merchants_company_activated
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              elsif takeover_game? && @phase.name != 'I'
                or_round_finished
                or_set_finished
                new_takeover_round
              else
                @turn += 1
                or_round_finished
                new_stock_round
              end
            when G1833NE::Round::Takeover
              new_stock_round
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def new_takeover_round
          @log << '-- Takeover Round -- '
          takeover_round
        end

        def operating_order
          corporations = @corporations.select(&:floated?)
          if @turn == 1 && (@round_num || 1) == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
        end

        def upgrade_cost(tile, hex, entity, spender)
          [self.class::TILE_COST, super].max
        end

        def check_distance(route, visits, train = nil)
          train ||= route.train
          has_extension = train.distance.is_a?(Array) && train.distance.any? { |h| h['extension'] }

          return super unless has_extension
          raise RouteTooLong, 'Route has no legal main range' if visits.any? && main_range(route, visits, train).empty?
        end

        def check_connected(route, corporation)
          paths = route.ordered_paths

          paths.each_cons(2) do |a, b|
            next if a.connects_to?(b, corporation) || blocked_join_legal?(route, a, b, corporation)

            raise GameError, 'Route is not connected'
          end
        end

        def within_main_range?(entries, visits, train)
          return true if visits.empty?

          rows = entries.map { |h| { nodes: h['nodes'], visit: h['visit'] || h['pay'] } }

          visits.group_by { |v| stop_type(v, train) }
                .sort_by { |t, _| rows.count { |r| r[:nodes].include?(t) } }
                .all? do |type, group|
            num = group.sum(&:visit_cost)
            rows.each do |row|
              usable = row[:nodes].include?(type) && row[:visit].positive?

              next unless usable

              take = [num, row[:visit]].min
              row[:visit] -= take
              num -= take
              break unless num.positive?
            end
            num.zero?
          end
        end

        def within_extension?(visits)
          visits.sum(&:visit_cost) <= INTERCONNECTION_EXTENSION.first['visit']
        end

        def blocked_for?(stop, corporation)
          stop.respond_to?(:blocks?) && stop.blocks?(corporation)
        end

        def blocked_join_legal?(route, a, b, corporation)
          shared = a.nodes & b.nodes
          return false unless shared.any? { |node| blocked_for?(node, corporation) }

          extension = extension_track(route)
          extension.include?(a) || extension.include?(b)
        end

        def route_path_dashes(route)
          extension_track(route).to_h { |p| [p, '12 6'] }
        end

        def main_range(route, stops = route.visited_stops, train = route.train)
          main = train.distance.reject { |h| h['extension'] }
          [stops, stops.reverse].filter_map do |ordered|
            longest = (1..ordered.size).select do |n|
              prefix = ordered.first(n)
              within_main_range?(main, prefix, train) &&
                prefix[1..-2].none? { |s| s.city? && blocked_for?(s, route.corporation) }
            end.max || 0
            range = ordered.first(longest)
            range if range.any? { |s| s.tokened_by?(route.corporation) }
          end.max_by(&:size) || []
        end

        def extension_stops(route)
          route.visited_stops - main_range(route, route.visited_stops)
        end

        def extension_track(route)
          extension = extension_stops(route)
          return [] if extension.empty?

          route.connection_data
            .select { |c| c[:chain] && (extension.include?(c[:left]) || extension.include?(c[:right])) }
            .flat_map { |c| c[:chain][:paths] }
        end

        def connection_bonus_tier
          case phase.name
          when 'I', 'II' then :i_ii
          when 'III', 'IV' then :iii_iv
          else :v
          end
        end

        # Ogdensburg RR owner doubles its bonuses in Phases I-III only.
        def ogdensburg_doubling?(corporation)
          ogdensburg_rr_owner?(corporation) && !after_phase_iii?
        end

        def bonus_value(bonus, route)
          value = bonus[:values][connection_bonus_tier]
          ogdensburg_bonus = bonus[:ogdensburg_owner] && ogdensburg_doubling?(route.corporation)

          return value unless ogdensburg_bonus

          value * 2
        end

        def any_stop_matches?(stops, names)
          stops.any? { |stop| names.any? { |name| stop_in_group?(stop, [name]) } }
        end

        def stop_in_group?(stop, group)
          group.include?(stop.tile.location_name) || group.include?(stop.hex.id)
        end

        def extended_distance(distance)
          base = if distance.is_a?(Numeric)
                   [{ 'nodes' => %w[city offboard town], 'pay' => distance, 'visit' => distance }]
                 else
                   distance
                 end
          base.reject { |h| h['extension'] }.map(&:dup) + INTERCONNECTION_EXTENSION.map(&:dup)
        end

        def interconnection_bonus(route, stops)
          interconnection_bonus_entries(route, stops).sum { |_label, value| value }
        end

        def interconnection_bonus_entries(route, _stops)
          range = main_range(route, route.visited_stops)
          return [] if range.empty?

          ends = [route.connection_data.first[:left], route.connection_data.last[:right]]
          far = ends.find { |n| range.none? { |s| s.hex.id == n.hex.id } }
          return [] if far.nil? || extension_stops(route).empty?

          claims = INTERCONNECTION_BONUSES.map do |bonus|
            next nil unless any_stop_matches?(range, bonus[:origin])
            next nil unless any_stop_matches?([far], bonus[:destination])

            value = bonus_value(bonus, route)
            value.positive? ? [bonus[:label], value] : nil
          end.compact

          best = claims.max_by { |_label, value| value }
          best ? [best] : []
        end

        INTERCONNECTION_BONUSES = [
          {
            label: 'Albany/Troy to Boston intercx bonus',
            origin: %w[Albany Troy],
            destination: %w[Boston],
            values: { i_ii: 50, iii_iv: 0, v: 0 },
          },
          {
            label: 'Montreal to Boston intercx bonus',
            origin: %w[Montreal],
            destination: %w[Boston],
            values: { i_ii: 70, iii_iv: 90, v: 0 },
          },
          {
            label: 'Boston to Montreal intercx bonus',
            origin: %w[Boston],
            destination: %w[Montreal],
            values: { i_ii: 30, iii_iv: 50, v: 0 },
          },
          {
            label: 'Boston to Ogdensburg intercx bonus',
            origin: %w[Boston],
            destination: %w[Ogdensburg],
            values: { i_ii: 30, iii_iv: 50, v: 0 },
          },
          {
            label: 'Ogdensburg to Boston intercx bonus',
            origin: %w[Ogdensburg],
            destination: %w[Boston],
            values: { i_ii: 40, iii_iv: 70, v: 0 },
            ogdensburg_owner: true,
          },
          {
            label: 'Montreal to Portland intercx bonus',
            origin: %w[Montreal],
            destination: %w[Portland],
            values: { i_ii: 30, iii_iv: 60, v: 40 },
          },
          {
            label: 'Portland to Montreal intercx bonus',
            origin: %w[Portland],
            destination: %w[Montreal],
            values: { i_ii: 30, iii_iv: 60, v: 40 },
          },
        ].map(&:freeze).freeze

        def direct_connection_bonus(route, stops)
          direct_bonus_entries(route, stops).sum { |_label, value| value.to_i }
        end

        def direct_bonus_entries(route, _stops)
          range = main_range(route, route.visited_stops)
          return [] if range.size < 2

          DIRECT_CONNECTION_BONUSES.map do |bonus|
            group_a, group_b = bonus[:groups]
            matched = range.any? { |s| stop_in_group?(s, group_a) } &&
                      range.any? { |s| stop_in_group?(s, group_b) }
            next nil unless matched

            value = bonus_value(bonus, route)
            value.positive? ? [bonus[:label], value] : nil
          end.compact
        end

        DIRECT_CONNECTION_BONUSES = [
          {
            label: 'Albany/Troy and Boston direct bonus',
            groups: [%w[Albany Troy], %w[Boston]],
            values: { i_ii: 100, iii_iv: 0, v: 0 },
          },
          { label: 'NYC and Boston direct bonus', groups: [['New York'], %w[Boston]], values: { i_ii: 0, iii_iv: 60, v: 80 } },
          {
            label: 'Montreal and Boston direct bonus',
            groups: [%w[Montreal], %w[Boston]],
            values: { i_ii: 150, iii_iv: 200, v: 0 },
          },
          {
            label: 'Ogdensburg and Boston direct bonus',
            groups: [%w[Boston], %w[Ogdensburg]],
            values: { i_ii: 120, iii_iv: 180, v: 0 },
            ogdensburg_owner: true,
          },
          {
            label: 'Montreal and Portland direct bonus',
            groups: [%w[Montreal], %w[Portland]],
            values: { i_ii: 60, iii_iv: 120, v: 80 },
          },
          {
            label: 'Montreal and New Haven/Norwich direct bonus',
            groups: [%w[Montreal], ['New Haven', 'Norwich']],
            values: { i_ii: 0, iii_iv: 50, v: 80 },
          },
        ].map(&:freeze).freeze

        def revenue_for(route, stops)
          stops.sum { |stop| stop.route_revenue(route.phase, route.train) } +
            direct_connection_bonus(route, stops) +
            interconnection_bonus(route, stops)
        end

        def revenue_stops(route)
          return super unless route.connection_hexes

          main_range(route, route.visited_stops)
        end

        def revenue_str(route)
          range = main_range(route, route.visited_stops)
          ordered = route.visited_stops
          ordered = ordered.reverse if range.any? && ordered.last == range.first
          base = ordered.map do |stop|
            range.include?(stop) ? stop.hex.name : "(#{stop.hex.name})"
          end.join('-')

          entries = direct_bonus_entries(route, nil) + interconnection_bonus_entries(route, nil)
          return base if entries.empty?

          bonuses = entries.map { |label, value| "#{label} #{format_currency(value)}" }.join(', ')
          "#{base} (#{bonuses})"
        end

        def sellable_bundles(player, corporation)
          return [] if corporation.receivership?

          super
        end

        def buying_power(entity, **)
          entity.cash + (issuable_shares(entity).map(&:price).max || 0)
        end

        def total_emr_buying_power(player, corporation)
          emergency = (issuable = emergency_issuable_cash(corporation)).zero?
          corporation.cash + issuable + liquidity(player, emergency: emergency)
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G1846::Step::IssueShares) }.active?

          num_shares = entity.num_player_shares - entity.num_market_shares
          bundles = bundles_for_corporation(entity, entity)
          share_price = stock_market.find_share_price(entity, :left).price

          bundles
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.num_shares > num_shares }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G1846::Step::IssueShares) }.active?

          share_price = stock_market.find_share_price(entity, :right).price

          bundles_for_corporation(share_pool, entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def emergency_issuable_bundles(corp)
          return [] if corp.trains.any?
          return [] if @round.emergency_issued
          return [] unless (train = @depot.min_depot_train)

          min_train_price, max_train_price = train.variants.map { |_, v| v[:price] }.minmax
          return [] if corp.cash >= max_train_price

          bundles = bundles_for_corporation(corp, corp)

          num_issuable_shares = corp.num_player_shares - corp.num_market_shares
          bundles.reject! { |bundle| bundle.num_shares > num_issuable_shares }

          bundles.each do |bundle|
            directions = [:left] * (1 + bundle.num_shares)
            bundle.share_price = stock_market.find_share_price(corp, directions).price
          end

          # cannot issue shares that generate no money
          bundles.reject! { |b| b.price.zero? }

          bundles.sort_by!(&:price)

          # Cannot issue more shares than needed to buy the train from the bank
          # (but may buy either variant)
          train_buying_bundles = bundles.select { |b| (corp.cash + b.price) >= min_train_price }
          if train_buying_bundles.any?
            bundles = train_buying_bundles

            index = bundles.find_index { |b| (corp.cash + b.price) >= max_train_price }
            return bundles.take(index + 1) if index

            return bundles
          end

          # if a train cannot be afforded, issue all possible shares
          biggest_bundle = bundles.max_by(&:num_shares)
          return [biggest_bundle] if biggest_bundle

          []
        end

        def takeover_game?
          @takeover_game ||= @optional_rules&.include?(:takeover_game)
        end

        def after_phase_i?
          phase.name != 'I'
        end

        def after_phase_iii?
          %w[IV V].include?(phase.name)
        end

        def lowell_merchants_company
          @lowell_merchants_company ||= company_by_id('P2')
        end

        def activate_lowell_merchants_company!
          @lowell_merchants_company_activated = true
        end

        def remove_lowell_merchants_ability!
          corp = lowell_merchants_company.owner
          ability = corp.all_abilities.find { |a| a.type == :tile_discount }

          corp.remove_ability(ability)
          if hex_by_id('G20').tile.color == :white
            @log << "#{corp.name} forfeits #{lowell_merchants_company.name}'s ability to lay a tile in G20 for free."
          end

          @lowell_merchants_company_activated = false
        end

        def ogdensburg_rr
          @ogdensburg_rr ||= company_by_id('P4')
        end

        def ogdensburg_rr_owner?(corporation)
          corporation == ogdensburg_rr.owner
        end
      end
    end
  end
end
