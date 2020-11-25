# frozen_string_literal: true

require_relative '../config/game/g_1860'
require_relative 'base'
require_relative '../g_1860/bank'

module Engine
  module Game
    class G1860 < Base
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
      GAME_PUBLISHER = :zman_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1860'

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :any_time
      SELL_BUY_ORDER = :sell_buy

      SEPARATE_BANKS = true
      COBANK_CASH = 15_000

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

      HALT_SUBSIDY = 10

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'fishbourne_to_bank' => ['Fishbourne', 'Fishbourne Ferry Company available for purchase']
      ).freeze

      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded_or_city, upgrade: false }].freeze

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

      def setup
        @bankrupt_corps = []
        @receivership_corps = []
        @insolvent_corps = []
        @closed_corps = []
        @highest_layer = 1
        @node_distances = {}
        @path_distances = {}
        @hex_distances = {}

        reserve_share('BHI&R')
        reserve_share('FYN')
        reserve_share('C&N')
        reserve_share('IOW')
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
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::G1860::Track,
          Step::Token,
          Step::G1860::Route,
          Step::G1860::Dividend,
          Step::BuyTrain,
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

      def or_set_finished
        check_new_layer
      end

      def bank_cash
        self.class::BANK_CASH - @players.sum(&:cash)
      end

      def event_fishbourne_to_bank!
        ffc = @companies.find { |c| c.sym == 'FFC' }
        ffc.owner = @bank
        @log << "#{ffc.name} is now available for purchase from the Bank"
      end

      def float_corporation(corporation)
        @log << "#{corporation.name} floats"

        @bank.spend(corporation.par_price.price * 10, corporation)
        @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
      end

      def corp_bankrupt?(corp)
        @bankrupt_corps.include?(corp)
      end

      def corp_hi_par(corp)
        (corp_bankrupt?(corp) ? REPAR_RANGE[corp_layer(corp)] : PAR_RANGE[corp_layer(corp)]).last
      end

      def corp_lo_par(corp)
        (corp_bankrupt?(corp) ? REPAR_RANGE[corp_layer(corp)] : PAR_RANGE[corp_layer(corp)]).first
      end

      def corp_layer(corp)
        LAYER_BY_NAME[corp.name]
      end

      def par_prices(corp)
        par_prices = corp_bankrupt?(corp) ? repar_prices : stock_market.par_prices
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
        layers.empty? ? 1 : layers.max + 1
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

      def sell_shares_and_change_price(bundle)
        corporation = bundle.corporation
        price = corporation.share_price.price

        @share_pool.sell_shares(bundle)
        num_shares = bundle.num_shares
        num_shares -= 1 if corporation.share_price.type == :ignore_one_sale
        num_shares.times { @stock_market.move_left(corporation) }
        log_share_price(corporation, price)
      end

      def close_other_companies!(company)
        return unless @companies.reject { |c| c == company }.reject(&:closed?)

        @corporations.each { |corp| corp.shares.each { |share| share.buyable = true } }
        @companies.reject { |c| c == company }.each(&:close!)
        @log << '-- Event: starting private companies close --'
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
            if node.city? && node.blocks?(corporation)
              game_error('Route can only bypass one tokened-out city') if blocked
              blocked = node
            end
          end
        end

        paths_ = route.paths.uniq
        token = blocked if blocked
        game_error('Route is not connected') if token.select(paths_, corporation: route.corporation).size != paths_.size

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

      def max_halts(route)
        # FIXME: need to ignore halts after formation of Southern Railway
        visits = route.visited_stops
        return 0 if visits.empty?

        cities = visits.select { |node| node.city? || node.offboard? }
        halts = visits.select(&:halt?)
        th_allowance = route.train.distance[-1]['pay'] + route.train.distance[0]['pay'] - cities.size
        [halts.size, th_allowance].min
      end

      def compute_stops(route)
        # FIXME: need to ignore halts after formation of Southern Railway
        # will need to be modifed for original rules option
        visits = route.visited_stops
        return [] if visits.empty?

        # no choice about citys/offboards => they must be stops
        stops = visits.select { |node| node.city? || node.offboard? }

        # in 1860, unused city/offboard allowance can be used for towns/halts
        c_allowance = route.train.distance[0]['pay']
        th_allowance = route.train.distance[-1]['pay'] + c_allowance - stops.size

        # add in halts requested
        halts = visits.select(&:halt?)
        num_halts = [halts.size, (route.halts || 0)].min
        if num_halts.positive?
          stops.concat(halts.take(num_halts))
          th_allowance -= num_halts
        end

        # pick highest revenue towns
        towns = visits.select { |node| node.town? && !node.halt? }
        num_towns = [th_allowance, towns.size].min
        if num_towns.positive?
          stops.concat(towns.sort_by(&:revenue).take(num_towns))
          th_allowance -= num_towns
        end

        # if this is first time for this route, add as many halts as possible
        if !route.halts && halts.any? && th_allowance.positive?
          num_halts = [halts.size, th_allowance].min
          stops.concat(halts.take(num_halts))
        end

        route.halts = num_halts if halts.any?

        stops
      end

      def route_distance(route)
        n_cities = route.stops.select { |n| n.city? || n.offboard? }.size
        n_towns = route.stops.select { |n| n.town? && !n.halt? }.size
        "#{n_cities}+#{n_towns}"
      end

      def revenue_for(route, stops)
        stops.sum { |stop| stop.route_base_revenue(route.phase, route.train) }
      end

      def subsidy_for(_route, stops)
        stops.select(&:halt?).size * HALT_SUBSIDY
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
