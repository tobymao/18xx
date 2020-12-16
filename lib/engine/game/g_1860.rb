# frozen_string_literal: true

require_relative '../config/game/g_1860'
require_relative 'base'
require_relative '../g_1860/bank'
require_relative '../g_1860/share_pool'

module Engine
  module Game
    class G1860 < Base
      attr_reader :nationalization, :sr_after_southern

      register_colors(black: '#000000',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#ff0000',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1860::JSON)

      GAME_LOCATION = 'Isle of Wight'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/79633/second-edition-rules'
      GAME_DESIGNER = 'Mike Hutton'
      GAME_PUBLISHER = nil
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1860'

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :any_time
      SELL_BUY_ORDER = :sell_buy
      MARKET_SHARE_LIMIT = 100
      TRAIN_PRICE_MIN = 10
      TRAIN_PRICE_MULTIPLE = 10

      COMPANY_SALE_FEE = 30

      SOLD_OUT_INCREASE = false

      STOCKMARKET_COLORS = {
        par: :yellow,
        endgame: :orange,
        close: :purple,
        repar: :gray,
        ignore_one_sale: :olive,
        multiple_buy: :brown,
        unlimited: :orange,
        no_cert_limit: :yellow,
        liquidation: :red,
        acquisition: :yellow,
        safe_par: :white,
      }.freeze

      MARKET_TEXT = { par: 'Par values (varies by corporation)',
                      no_cert_limit: 'UNUSED',
                      unlimited: 'UNUSED',
                      multiple_buy: 'UNUSED',
                      close: 'Corporation bankrupts',
                      endgame: 'End game trigger',
                      liquidation: 'UNUSED',
                      repar: 'Par values after bankruptcy (varies by corporation)',
                      ignore_one_sale: 'Ignore first share sold when moving price' }.freeze

      HALT_SUBSIDY = 10

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'fishbourne_to_bank' => ['Fishbourne', 'Fishbourne Ferry Company available for purchase.'],
        'relax_cert_limit' => ['No Cert Limit', "No limit on certificates/player; Selling doesn't reduce share price."],
        'southern_forms' => ['Southern Forms', 'Southern RR forms; No track or token after the next SR.']
      ).freeze

      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded_or_city, upgrade: false }].freeze

      GAME_END_CHECK = { stock_market: :current_or, bank: :current_or, custom: :immediate }.freeze

      PAR_RANGE = {
        1 => [74, 100],
        2 => [62, 82],
        3 => [58, 68],
        4 => [54, 62],
      }.freeze

      REPAR_RANGE = {
        1 => [40, 100],
        2 => [40, 82],
        3 => [40, 68],
        4 => [40, 62],
      }.freeze

      LAYER_BY_NAME = {
        'C&N' => 1,
        'IOW' => 1,
        'IWNJ' => 2,
        'FYN' => 2,
        'NGStL' => 3,
        'BHI&R' => 3,
        'S&C' => 4,
        'VYSC' => 4,
      }.freeze

      NO_ROTATION_TILES = %w[
        758
        761
        763
        773
        775
      ].freeze

      def init_bank
        # amount doesn't matter here
        Engine::G1860::Bank.new(20_000, self, log: @log)
      end

      def init_share_pool
        Engine::G1860::SharePool.new(self)
      end

      def setup
        @bankrupt_corps = []
        @insolvent_corps = []
        @nationalized_corps = []
        @highest_layer = 1
        @node_distances = {}
        @path_distances = {}
        @hex_distances = {}

        reserve_share('BHI&R')
        reserve_share('FYN')
        reserve_share('C&N')
        reserve_share('IOW')

        @no_price_drop_on_sale = false
        @southern_formed = false
        @sr_after_southern = false
        @nationalization = false
      end

      def share_prices
        repar_prices
      end

      def reserve_share(name)
        @corporations.find { |c| c.name == name }.shares.last.buyable = false
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G1860::HomeTrack,
          Step::G1860::Exchange,
          Step::G1860::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::G1860::Operating.new(self, [
          Step::DiscardTrain,
          Step::G1860::Track,
          Step::G1860::Token,
          Step::G1860::Route,
          Step::G1860::Dividend,
          Step::G1860::BuyTrain,
        ], round_num: round_num)
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET, [], zigzag: true)
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::G1860::BuyCert,
        ])
      end

      def init_round_finished
        players_by_cash = @players.sort_by(&:cash).reverse

        if players_by_cash[0].cash > players_by_cash[1].cash
          player = players_by_cash[0]
          reason = 'most cash'
        else
          # tie-breaker: lowest total face value in private companies
          player = @players.select { |p| p.companies.any? }.min_by { |p| p.companies.sum(&:value) }
          reason = 'least value of private companies'
        end
        @log << "#{player.name} has #{reason}"

        @players.rotate!(@players.index(player))
      end

      def new_stock_round
        trigger_sr_after_southern! if @southern_formed

        super
      end

      def or_set_finished
        check_new_layer
      end

      def next_round!
        @round =
          case @round
          when Round::Stock
            @operating_rounds = @phase.operating_rounds
            reorder_players
            trigger_nationalization! if check_nationalize?
            new_operating_round
          when Round::Operating
            if @round.round_num < @operating_rounds || check_nationalize?
              trigger_nationalization! if check_nationalize?
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
            reorder_players
            new_stock_round
          end
      end

      def round_description(name, round_number = nil)
        round_number ||= @round.round_num
        description = "#{name} Round "

        total = total_rounds(name)

        description += @turn.to_s unless @turn.zero?
        description += '.' if total && !@turn.zero?
        description += round_number.to_s if total
        description += " (of #{total})" if total && !@nationalization
        description += ' (Nationalization)' if total && @nationalization

        description.strip
      end

      def bank_cash
        self.class::BANK_CASH - @players.sum(&:cash)
      end

      def check_bank_broken!
        @bank.break! if !@nationalization && bank_cash.negative?
      end

      def player_value(player)
        player.cash +
          player.shares.select { |s| s.corporation.ipoed & s.corporation.trains.any? }.sum(&:price) +
          player.shares.select { |s| s.corporation.ipoed & s.corporation.trains.none? }.sum { |s| (s.price / 2).to_i } +
          player.companies.sum(&:value)
      end

      def liquidity(player)
        company_value = turn > 1 ? player.companies.sum { |c| c.value - COMPANY_SALE_FEE } : 0

        player.cash +
          player.shares.select { |s| s.corporation.ipoed & s.corporation.trains.any? }.sum(&:price) +
          player.shares.select { |s| s.corporation.ipoed & s.corporation.trains.none? }.sum { |s| (s.price / 2).to_i } +
          company_value
      end

      def event_fishbourne_to_bank!
        ffc = @companies.find { |c| c.sym == 'FFC' }
        ffc.owner = @bank
        @log << "#{ffc.name} is now available for purchase from the Bank"
      end

      def event_relax_cert_limit!
        @log << 'Selling shares no longer decreases share value; No limit on certificates per player.'
        @no_price_drop_on_sale = true
        @cert_limit = 999
      end

      def event_southern_forms!
        @log << 'Southern Railway Forms; End of game triggered (via Nationalization).'
        @southern_formed = true
      end

      def trigger_sr_after_southern!
        return if @sr_after_southern

        @log << 'Stock round after Southern has formed - No track or token building, halts are ignored'
        @sr_after_southern = true
      end

      def trigger_nationalization!
        return if @nationalization

        @log << 'All non-Receivership corporations own at least one train. Nationalization begins.'
        @nationalization = true
      end

      def check_nationalize?
        return false unless @southern_formed
        return true if @nationalization

        @corporations.select { |c| c.ipoed && !c.receivership? }.all? { |c| c.trains.any? }
      end

      # OR has just finished, find two lowest revenues and nationalize the corporations
      # associated with each
      def nationalize_corps!
        revenues = @corporations.select { |c| c.floated? && !nationalized?(c) }
          .map { |c| [c, c.operating_history[c.operating_history.keys.max].revenue] }.to_h

        sorted_corps = revenues.keys.sort_by { |c| c.operating_history[c.operating_history.keys.max].revenue }

        if sorted_corps.size < 3
          # if two or less corps left, they are both nationalized
          sorted_corps.each { |c| make_nationalized!(c) }
        else
          # all companies with the lowest revenue are nationalized
          # if only one has the lowest revenue, then all companies with the next lowest revenue are nationalized
          min_revenue = revenues[sorted_corps[0]]
          next_revenue_corp = sorted_corps.find { |c| revenues[c] > min_revenue }
          next_revenue = revenues[next_revenue_corp] if next_revenue_corp

          grouped = revenues.keys.group_by { |c| revenues[c] }
          grouped[min_revenue].each { |c| make_nationalized!(c) }
          grouped[next_revenue].each { |c| make_nationalized!(c) } if next_revenue_corp && grouped[min_revenue].one?
        end
      end

      # game ends when all floated corps have nationalized
      def custom_end_game_reached?
        return false unless @nationalization
        return false unless @round.finished?

        nationalize_corps! if @nationalization
        @corporations.select(&:floated?).all? { |corp| nationalized?(corp) }
      end

      def insolvent?(corp)
        @insolvent_corps.include?(corp)
      end

      def make_insolvent(corp)
        return if insolvent?(corp)

        @insolvent_corps << corp
        @log << "#{corp.name} is now Insolvent"
      end

      def clear_insolvent(corp)
        return unless insolvent?(corp)

        @insolvent_corps.delete(corp)
        @log << "#{corp.name} is no longer Insolvent"
      end

      def bankrupt?(corp)
        @bankrupt_corps.include?(corp)
      end

      def make_bankrupt!(corp)
        return if bankrupt?(corp)

        @bankrupt_corps << corp
        @log << "#{corp.name} enters Bankruptcy"

        # un-IPO the corporation
        corp.share_price.corporations.delete(corp)
        corp.share_price = nil
        corp.par_price = nil
        corp.ipoed = false
        corp.unfloat!

        # return shares to IPO
        corp.share_holders.keys.each do |share_holder|
          next if share_holder == corp

          shares = share_holder.shares_by_corporation[corp].compact
          corp.share_holders.delete(share_holder)
          shares.each do |share|
            share_holder.shares_by_corporation[corp].delete(share)
            share.owner = corp
            corp.shares_by_corporation[corp] << share
          end
        end
        corp.shares_by_corporation[corp].sort_by!(&:index)
        corp.share_holders[corp] = 100
        corp.owner = nil

        # "flip" any tokens for corporation placed on map
        corp.tokens.each do |token|
          token.status = :flipped if token.used
        end

        # find new priority deal: player with lowest total share count
        @players.rotate!(@players.index(priority_deal_player))
        player = @players.min_by { |p| p.shares.sum(&:percent) }
        @players.rotate!(@players.index(player))
        @log << "#{@players.first.name} has priority deal"

        # restart stock round if in middle of one
        @round.clear_cache!
        return unless @round.class == Round::Stock

        @log << 'Restarting Stock Round'
        @round.entities.each(&:unpass!)
        @round = stock_round
      end

      def clear_bankrupt!(corp)
        return unless bankrupt?(corp)

        # Designer says that bankrupt corps keep insolvency flag

        # "unflip" any tokens for corporation placed on map
        corp.tokens.each do |token|
          token.status = nil if token.used
        end
        @bankrupt_corps.delete(corp)
      end

      def nationalized?(corp)
        @nationalized_corps.include?(corp)
      end

      def make_nationalized!(corp)
        return if nationalized?(corp)

        @log << "#{corp.name} is Nationalized and will cease to operate."
        @nationalized_corps << corp
      end

      def status_str(corp)
        status = 'Insolvent' if insolvent?(corp)
        status = status ? status + ', Receivership' : 'Receivership' if corp.receivership?
        status = status ? status + ', Bankrupt' : 'Bankrupt' if bankrupt?(corp)
        status = status ? status + ', Nationalized' : 'Nationalized' if nationalized?(corp)
        status
      end

      def corp_hi_par(corp)
        (bankrupt?(corp) ? REPAR_RANGE[corp_layer(corp)] : PAR_RANGE[corp_layer(corp)]).last
      end

      def corp_lo_par(corp)
        (bankrupt?(corp) ? REPAR_RANGE[corp_layer(corp)] : PAR_RANGE[corp_layer(corp)]).first
      end

      def corp_layer(corp)
        LAYER_BY_NAME[corp.name]
      end

      def par_prices(corp)
        par_prices = bankrupt?(corp) ? repar_prices : stock_market.par_prices
        par_prices.select { |p| p.price <= corp_hi_par(corp) && p.price >= corp_lo_par(corp) }
      end

      def repar_prices
        @repar_prices ||= stock_market.market.first.select { |p| p.type == :repar || p.type == :par }
      end

      def can_ipo?(corp)
        corp_layer(corp) <= current_layer
      end

      def check_new_layer
        layer = current_layer
        @log << "-- Layer #{layer} corporations now available --" if layer > @highest_layer
        @highest_layer = layer
      end

      def current_layer
        layers = LAYER_BY_NAME.select do |name, _layer|
          corp = @corporations.find { |c| c.name == name }
          corp.num_ipo_shares.zero? || corp.operated?
        end.values
        layers.empty? ? 1 : [layers.max + 1, 4].min
      end

      def float_corporation(corporation)
        clear_bankrupt!(corporation)
        super
      end

      def action_processed(_action)
        @corporations.each do |corporation|
          make_bankrupt!(corporation) if corporation.share_price&.type == :close
        end
      end

      def sorted_corporations
        @corporations.sort_by { |c| corp_layer(c) }
      end

      def corporation_available?(entity)
        entity.corporation? && can_ipo?(entity)
      end

      def bundles_for_corporation(share_holder, corporation, shares: nil)
        return [] unless corporation.ipoed

        shares = (shares || share_holder.shares_of(corporation)).sort_by(&:price)

        bundles = shares.flat_map.with_index do |share, index|
          bundle = shares.take(index + 1)
          percent = bundle.sum(&:percent)
          bundles = [Engine::ShareBundle.new(bundle, percent)]
          if share.president
            normal_percent = corporation.share_percent
            difference = corporation.presidents_percent - normal_percent
            num_partial_bundles = difference / normal_percent
            (1..num_partial_bundles).each do |n|
              bundles.insert(0, Engine::ShareBundle.new(bundle, percent - (normal_percent * n)))
            end
          end
          bundles.each { |b| b.share_price = (b.price_per_share / 2).to_i if corporation.trains.empty? }
          bundles
        end

        bundles
      end

      def selling_movement?(corporation)
        corporation.operated? && !@no_price_drop_on_sale
      end

      def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
        corporation = bundle.corporation
        price = corporation.share_price.price

        @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
        num_shares = bundle.num_shares
        num_shares -= 1 if corporation.share_price.type == :ignore_one_sale
        num_shares.times { @stock_market.move_left(corporation) } if selling_movement?(corporation)
        log_share_price(corporation, price)
      end

      def close_other_companies!(company)
        return unless @companies.reject { |c| c == company }.reject(&:closed?)

        @corporations.each { |corp| corp.shares.each { |share| share.buyable = true } }
        @companies.reject { |c| c == company }.each(&:close!)
        @log << '-- Event: starting private companies close --'
      end

      def game_ending_description
        reason, after = game_end_check
        return unless after

        after_text = ''

        unless @finished
          after_text = case after
                       when :immediate
                         ' : Game Ends immediately'
                       when :current_round
                         if @round.is_a?(Round::Operating)
                           " : Game Ends at conclusion of this OR (#{turn}.#{@round.round_num})"
                         else
                           " : Game Ends at conclusion of this round (#{turn})"
                         end
                       when :current_or
                         " : Game Ends at conclusion of this OR (#{turn}.#{@round.round_num})"
                       when :full_or
                         " : Game Ends at conclusion of #{round_end.short_name} #{turn}.#{operating_rounds}"
                       when :one_more_full_or_set
                         " : Game Ends at conclusion of #{round_end.short_name}"\
                           " #{@final_turn}.#{final_operating_rounds}"
                       end
        end

        reason_map = {
          bank: 'Bank Broken',
          bankrupt: 'Bankruptcy',
          stock_market: 'Company hit max stock value',
          final_train: 'Final train was purchased',
          custom: 'Nationalization complete',
        }
        "#{reason_map[reason]}#{after_text}"
      end

      def train_help(trains)
        help = []

        if trains.select { |t| t.owner == @depot }.any?
          help << 'Leased trains ignore town/halt allowance.'
          help << "Revenue = #{format_currency(40)} + number_of_stops * #{format_currency(20)}"
        end

        help
      end

      def train_owner(train)
        train.owner == @depot ? lessee : train.owner
      end

      def lessee
        current_entity
      end

      def route_trains(entity)
        if insolvent?(entity)
          [@depot.min_depot_train]
        else
          super
        end
      end

      def biggest_train(corporation)
        val = corporation.trains.map { |t| t.distance[0]['pay'] }.max || 0
        val
      end

      def get_token_cities(corporation)
        tokens = []
        hexes.each do |hex|
          hex.tile.cities.each do |city|
            next unless city.tokened_by?(corporation)

            tokens << city
          end
        end
        tokens
      end

      def node_distance_walk(node, distance, node_distances: {}, corporation: nil, path_distances: {})
        return if (node_distances[node] || 999) <= distance

        node_distances[node] = distance
        distance += 1 if node.city?

        return if corporation && node.blocks?(corporation)

        node.paths.each do |node_path|
          path_distance_walk(node_path, distance, path_distances: path_distances) do |path|
            yield path, distance
            path.nodes.each do |next_node|
              next if next_node == node
              next if path.terminal?

              node_distance_walk(
                next_node,
                distance,
                node_distances: node_distances,
                corporation: corporation,
                path_distances: path_distances,
              ) { |p, d| yield p, d }
            end
          end
        end
      end

      def lane_match?(lanes0, lanes1)
        lanes0 && lanes1 && lanes1[0] == lanes0[0] && lanes1[1] == (lanes0[0] - lanes0[1] - 1)
      end

      def path_distance_walk(path, distance, skip: nil, jskip: nil, path_distances: {})
        return if (path_distances[path] || 999) <= distance

        path_distances[path] = distance

        yield path

        if path.junction && path.junction != jskip
          path.junction.paths.each do |jp|
            path_distance_walk(jp, distance, jskip: @junction, path_distances: path_distances) { |p| yield p }
          end
        end

        path.exits.each do |edge|
          next if edge == skip
          next unless (neighbor = path.hex.neighbors[edge])

          np_edge = path.hex.invert(edge)

          neighbor.paths[np_edge].each do |np|
            next unless lane_match?(path.exit_lanes[edge], np.exit_lanes[np_edge])

            path_distance_walk(np, distance, skip: np_edge, path_distances: path_distances) { |p| yield p }
          end
        end
      end

      def clear_distances
        @node_distances.clear
        @path_distances.clear
        @hex_distances.clear
      end

      def node_distances(corporation)
        compute_distance_graph(corporation) unless @node_distances[corporation]
        @node_distances[corporation]
      end

      def path_distances(corporation)
        compute_distance_graph(corporation) unless @path_distances[corporation]
        @path_distances[corporation]
      end

      def hex_distances(corporation)
        compute_distance_graph(corporation) unless @hex_distances[corporation]
        @hex_distances[corporation]
      end

      def compute_distance_graph(corporation)
        tokens = get_token_cities(corporation)
        n_distances = {}
        p_distances = {}
        h_distances = {}

        tokens.each do |node|
          node_distance_walk(node, 0, node_distances: n_distances,
                                      corporation: corporation, path_distances: p_distances) do |path, dist|
            hex = path.hex
            h_distances[hex] = dist if !h_distances[hex] || h_distances[hex] > dist
          end
        end

        @node_distances[corporation] = n_distances
        @path_distances[corporation] = p_distances
        @hex_distances[corporation] = h_distances
      end

      # needed for custom_node_walk
      def custom_node_select(node, paths, corporation: nil)
        on = paths.map { |p| [p, 0] }.to_h

        custom_node_walk(node, on: on, corporation: corporation) do |path|
          on[path] = 1 if on[path]
        end

        on.keys.select { |p| on[p] == 1 }
      end

      # needed for custom_blocks?
      def custom_node_walk(node, visited: nil, on: nil, corporation: nil, visited_paths: {})
        return if visited&.[](node)

        visited = visited&.dup || {}
        visited[node] = true

        node.paths.each do |node_path|
          node_path.walk(visited: visited_paths, on: on) do |path, vp|
            yield path
            path.nodes.each do |next_node|
              next if next_node == node
              next if corporation && custom_blocks?(next_node, corporation)
              next if path.terminal?

              custom_node_walk(
                next_node,
                visited: visited,
                on: on,
                corporation: corporation,
                visited_paths: visited_paths.merge(vp),
              ) { |p| yield p }
            end
          end
        end
      end

      # needed for :flipped check
      def custom_blocks?(node, corporation)
        return false unless node.city?
        return false unless corporation
        return false if node.tokened_by?(corporation)
        return false if node.tokens.include?(nil)
        return false if node.tokens.any? { |t| t&.type == :neutral || t&.status == :flipped }

        true
      end

      def legal_tile_rotation?(_entity, _hex, tile)
        return true unless NO_ROTATION_TILES.include?(tile.name)

        tile.rotation.zero?
      end

      # at least one route must include home token
      def check_home_token(corporation, routes)
        tokens = get_token_cities(corporation)
        home_city = tokens.find { |c| c.hex == hex_by_id(corporation.coordinates) }
        found = false
        routes.each { |r| found ||= r.visited_stops.include?(home_city) } if home_city
        game_error('At least one route must include home token') unless found
      end

      def visit_route(ridx, intersects, visited)
        return if visited[ridx]

        visited[ridx] = true
        intersects[ridx].each { |i| visit_route(i, intersects, visited) }
      end

      # all routes must intersect each other
      def check_intersection(routes)
        actual_routes = routes.reject { |r| r.connections.empty? }

        # build a map of which routes intersect with each route
        intersects = Hash.new { |h, k| h[k] = [] }
        actual_routes.each_with_index do |r, ir|
          actual_routes.each_with_index do |s, is|
            next if ir == is

            intersects[ir] << is if (r.visited_stops & s.visited_stops).any?
          end
          intersects[ir].uniq!
        end

        # starting with the first route, make sure every route can be visited
        visited = {}
        visit_route(0, intersects, visited)

        game_error('Routes must intersect with each other') if visited.size != actual_routes.size
      end

      def tokened_out?(route)
        visits = route.visited_stops
        return false unless visits.size > 2

        corporation = route.corporation
        visits[1..-2].any? { |node| node.city? && node.blocks?(corporation) }
      end

      def check_connected(route, token)
        visits = route.visited_stops
        blocked = nil

        if visits.size > 2
          corporation = route.corporation
          visits[1..-2].each do |node|
            if node.city? && custom_blocks?(node, corporation)
              game_error('Route can only bypass one tokened-out city') if blocked
              blocked = node
            end
          end
        end

        paths_ = route.paths.uniq
        token = blocked if blocked
        if custom_node_select(token, paths_, corporation: route.corporation).size != paths_.size
          game_error('Route is not connected')
        end

        return unless blocked && route.routes.any? { |r| r != route && tokened_out?(r) }

        game_error('Only one train can bypass a tokened-out city')
      end

      def check_distance(route, visits)
        # will need to be modifed for original rules option
        super
        game_error('Route cannot begin/end in a halt') if visits.first.halt? || visits.last.halt?
      end

      def check_hex_reentry(route)
        visited_hexes = {}
        last_hex = nil
        route.ordered_paths.each do |path|
          hex = path.hex
          game_error('Route cannot re-enter a hex') if hex != last_hex && visited_hexes[hex]

          visited_hexes[hex] = true
          last_hex = hex
        end
      end

      def check_other(route)
        check_hex_reentry(route)
      end

      def maximize_revenue?
        @nationalization
      end

      def ignore_halts?
        @sr_after_southern
      end

      def ignore_halt_subsidies?(route)
        route.train.owner == @depot
      end

      def ignore_second_allowance?(route)
        route.train.owner == @depot || @nationalization
      end

      def max_halts(route)
        visits = route.visited_stops
        return 0 if visits.empty? || ignore_halts?

        cities = visits.select { |node| node.city? || node.offboard? }
        towns = visits.select { |node| node.town? && !node.halt? }
        halts = visits.select(&:halt?)
        c_allowance = route.train.distance[0]['pay']
        th_allowance = if !ignore_second_allowance?(route)
                         route.train.distance[-1]['pay'] + c_allowance - cities.size
                       else
                         c_allowance - cities.size
                       end
        # if required to maximize revenue only use halts if there aren't enough cities or towns
        th_allowance = [th_allowance - towns.size, 0].max if maximize_revenue?
        [halts.size, th_allowance].min
      end

      def compute_stops(route)
        # will need to be modifed for original rules option
        visits = route.visited_stops
        return [] if visits.empty?

        # no choice about citys/offboards => they must be stops
        stops = visits.select { |node| node.city? || node.offboard? }

        # in 1860, unused city/offboard allowance can be used for towns/halts
        c_allowance = route.train.distance[0]['pay']
        th_allowance = if !ignore_second_allowance?(route)
                         route.train.distance[-1]['pay'] + c_allowance - stops.size
                       else
                         c_allowance - stops.size
                       end

        # add in halts requested (from previous run or UI button)
        #
        # reset requested halts to nil if no halts on route, ignoring halts, not using halt for subsidies,
        # maximum halts allowed is zero, or requested halts is greater than maximum allowed
        halts = visits.select(&:halt?)

        halt_max = max_halts(route)

        route.halts = nil if halts.empty? || ignore_halts? || ignore_halt_subsidies?(route) || halt_max.zero?
        route.halts = nil if route.halts && route.halts > halt_max

        num_halts = [halts.size, (route.halts || 0)].min
        if num_halts.positive?
          stops.concat(halts.take(num_halts))
          th_allowance -= num_halts
        end

        # after adding requested halts, pick highest revenue towns
        towns = visits.select { |node| node.town? && !node.halt? }
        num_towns = [th_allowance, towns.size].min
        if num_towns.positive?
          stops.concat(towns.sort_by { |t| t.uniq_revenues.first }.reverse.take(num_towns))
          th_allowance -= num_towns
        end

        # if requested halts is nil (i.e. this is first time for this route), add as many halts as possible if
        # there are halts on route, there is room for some, and we aren't ignoring halts
        if !route.halts && halts.any? && th_allowance.positive? && !ignore_halts?
          num_halts = [halts.size, th_allowance].min
          stops.concat(halts.take(num_halts))
        end

        # update route halts
        route.halts = num_halts if (num_halts.positive? || route.halts) && !ignore_halt_subsidies?(route)

        stops
      end

      def route_distance(route)
        n_cities = route.stops.select { |n| n.city? || n.offboard? }.size
        # halts are treated like towns for leased trains
        n_towns = if route.train.owner != @depot
                    route.stops.count { |n| n.town? && !n.halt? }
                  else
                    route.stops.count(&:town?)
                  end
        route.train.owner != @depot ? "#{n_cities}+#{n_towns}" : (n_cities + n_towns).to_s
      end

      def revenue_for(route, stops)
        if route.train.owner != @depot
          stops.sum { |stop| stop.route_base_revenue(route.phase, route.train) }
        else
          40 + 20 * stops.size
        end
      end

      def subsidy_for(route, stops)
        route.train.owner != @depot ? stops.count(&:halt?) * HALT_SUBSIDY : 0
      end

      def routes_revenue(routes)
        routes.sum(&:revenue)
      end

      def routes_subsidy(routes)
        routes.sum(&:subsidy)
      end
    end
  end
end
