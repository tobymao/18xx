# frozen_string_literal: true

require_relative '../config/game/g_1849'
require_relative 'base'
require_relative '../g_1849/corporation'
require_relative '../g_1849/stock_market'

module Engine
  module Game
    class G1849 < Base
      register_colors(black: '#000000',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#ff0000',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a',
                      goldenrod: '#f9b231')

      load_from_json(Config::Game::G1849::JSON)
      AXES = { x: :number, y: :letter }.freeze

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'Sicily'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/206628/1849-rules'
      GAME_DESIGNER = 'Federico Vellani'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849'

      # TODO: game ends immediately after a company that has reached 377 finishes operating
      GAME_END_CHECK = { bank: :full_or }.freeze

      # TODO: player leaves game or takes loan
      BANKRUPTCY_ALLOWED = false

      CLOSED_CORP_RESERVATIONS = :remain

      EBUY_OTHER_VALUE = false
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :operate
      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :down_per_10
      POOL_SHARE_DROP = :one

      # TODO: companies must be sold in operating order
      # SELL_ORDER = :market_value

      MARKET_TEXT = Base::MARKET_TEXT.merge(phase_limited: 'Can only enter during phase 16').freeze
      STOCKMARKET_COLORS = {
        par: :yellow,
        endgame: :orange,
        close: :purple,
        phase_limited: :blue,
      }.freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'green_par': ['144 Par Available',
                      'Corporations may now par at 144 (in addition to 67 and 100)'],
        'brown_par': ['216 Par Available',
                      'Corporations may now par at 216 (in addition to 67, 100, and 144)'],
        'earthquake': ['Messina Earthquake',
                       'Messina (B14) downgraded to yellow, tokens removed from game.
                        Cannot be upgraded until after next stock round']
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'blue_zone': ['Blue Zone Available', 'Corporation share prices can enter the blue zone'],
        'gray_uses_yellow': ['Yellow Revenues', 'Gray locations use yellow revenue values'],
        'gray_uses_green': ['Green Revenues', 'Gray locations use green revenue values'],
        'gray_uses_brown': ['Brown Revenues', 'Gray locations use brown revenue values']
      ).freeze

      GRAY_REVENUE_CENTERS =
        {
          'C1':
            {
              '4H': 20,
              '6H': 20,
              '8H': 30,
              '10H': 30,
              '12H': 40,
              '16H': 40,
            },
          'E1':
            {
              '4H': 20,
              '6H': 20,
              '8H': 30,
              '10H': 30,
              '12H': 40,
              '16H': 40,
            },
          'C15':
            {
              '4H': 10,
              '6H': 10,
              '8H': 30,
              '10H': 30,
              '12H': 90,
              '16H': 90,
            },
          'M9':
            {
              '4H': 20,
              '6H': 20,
              '8H': 30,
              '10H': 30,
              '12H': 40,
              '16H': 40,
            },
        }.freeze

      AFG_HEXES = %w[C1 H8 M9 M11 B14].freeze
      PORT_HEXES = %w[a12 A5 L14 N8].freeze

      def setup
        @corporations.sort_by! { rand }
        remove_corp if @players.size == 3
        @corporations.each do |c|
          c.next_to_par = false
          c.shares.last.last_cert = true
        end
        @corporations[0].next_to_par = true
      end

      def remove_corp
        removed = @corporations.pop
        @log << "Removed #{removed.name}"
      end

      def num_trains(train)
        fewer = @players.size < 4
        case train[:name]
        when '6H'
          fewer ? 3 : 4
        when '8H'
          fewer ? 2 : 3
        when '16H'
          fewer ? 4 : 5
        end
      end

      def after_par(corporation)
        super
        corporation.spend(corporation.token_fee, @bank)
        @log << "#{corporation.name} spends #{format_currency(corporation.token_fee)}
                 for tokens"
        corporation.next_to_par = false
        index = @corporations.index(corporation)

        @corporations[index + 1].next_to_par = true unless index == @corporations.length - 1
      end

      def home_token_locations(corporation)
        raise NotImplementedError unless corporation.name == 'AFG'

        AFG_HEXES.map { |coord| hex_by_id(coord) }.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
        end
      end

      def init_stock_market
        sm = Engine::G1849::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                            multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)

        sm.game = self

        sm.enable_par_price(68)
        sm.enable_par_price(100)

        sm
      end

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        self.class::CORPORATIONS.map do |corporation|
          Engine::G1849::Corporation.new(
            min_price: min_price,
            capitalization: self.class::CAPITALIZATION,
            **corporation.merge(corporation_opts),
          )
        end
      end

      def close_corporation(corporation, quiet: false)
        super
        corporation = reset_corporation(corporation)
        corporation.shares.last.last_cert = true
        @corporations.push(corporation)
        corporation.closed_recently = true
        corporation.next_to_par = true if @corporations[@corporations.length - 2].floated?
      end

      def new_stock_round
        @corporations.each { |c| c.closed_recently = false }
        super
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G1849::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
                               Step::Bankrupt,
                               Step::Exchange,
                               Step::SpecialTrack,
                               Step::BuyCompany,
                               Step::G1849::Track,
                               Step::Token,
                               Step::Route,
                               Step::G1849::Dividend,
                               Step::DiscardTrain,
                               Step::BuyTrain,
                               Step::G1849::IssueShares,
                               [Step::BuyCompany, blocks: true],
                             ], round_num: round_num)
      end

      def track_type(paths)
        types = paths.map(&:track).uniq
        game_error('Can only change track type at station.') if types.include?(:broad) && types.include?(:narrow)
        case
        when types.include?(:narrow)
          :narrow
        when types.include?(:broad)
          :broad
        else
          :dual
        end
      end

      def hex_edge_cost(conn, train)
        track = track_type(conn.paths)
        edges = conn.paths.each_cons(2).sum do |a, b|
          a.hex == b.hex ? 0 : 1
        end
        if train.name == 'R6H'
          track == :broad ? edges * 2 : edges
        else
          track == :narrow ? edges * 2 : edges
        end
      end

      def check_distance(route, _visits)
        limit = route.train.distance
        cost = route.connections.sum { |conn| hex_edge_cost(conn, route.train) }
        game_error("#{cost} is too many hex edges for #{route.train.name} train") if cost > limit
      end

      def check_other(route)
        return unless (route.stops.map(&:hex).map(&:id) & PORT_HEXES).any?

        game_error('Route must include two non-port stops.') unless route.stops.size > 2
      end

      def revenue_for(route, stops)
        stops.sum { |stop| stop_revenue(stop, route.phase, route.train) }
      end

      def stop_revenue(stop, phase, train)
        return stop.route_revenue(phase, train) unless GRAY_REVENUE_CENTERS.keys.include?(stop.hex.id)

        GRAY_REVENUE_CENTERS[stop.hex.id][@phase.name]
      end

      def issuable_shares(entity)
        return [] unless entity.operating_history.size > 1

        num_shares = 5 - entity.num_market_shares
        bundles = bundles_for_corporation(entity, entity)

        bundles.reject { |bundle| bundle.num_shares > num_shares || !last_cert_last?(bundle) }
      end

      def redeemable_shares(entity)
        return [] unless entity.operating_history.size > 1

        bundles_for_corporation(share_pool, entity)
          .reject { |bundle| bundle.shares.size > 1 || entity.cash < bundle.price || !last_cert_last?(bundle) }
      end

      def dumpable(bundle)
        return true unless bundle.presidents_share

        owner_percent = bundle.owner.percent_of(bundle.corporation)
        other_percent = @players.reject { |p| p.id == bundle.owner.id }.map { |o| o.percent_of(bundle.corporation) }.max

        other_percent > owner_percent - bundle.percent
      end

      def bundles_for_corporation(share_holder, corporation, shares: nil)
        return [] unless corporation.ipoed

        shares = (shares || share_holder.shares_of(corporation))

        bundles = (1..shares.size).flat_map do |n|
          shares.combination(n).to_a.map { |ss| Engine::ShareBundle.new(ss) }
        end

        (bundles.uniq do |b|
          [b.shares.count { |s| s.percent == 10 },
           b.presidents_share ? 1 : 0,
           b.shares.find(&:last_cert) ? 1 : 0]
        end).select { |b| dumpable(b) }.sort_by(&:percent)
      end

      def last_cert_last?(bundle)
        bundle = bundle.to_bundle
        last_cert = bundle.shares.find(&:last_cert)
        return true unless last_cert

        location = last_cert.corporation.shares.include?(last_cert) ? last_cert.corporation.shares : share_pool.shares
        location.size == bundle.shares.size
      end

      def new_track(old_tile, new_tile)
        # Assume path retention checked elsewhere
        old_track = old_tile.paths.map(&:track)
        added_track = new_tile.paths.map(&:track)
        old_track.each { |t| added_track.slice!(added_track.index(t) || added_track.size) }
        if added_track.include?(:dual)
          :dual
        else
          added_track.include?(:broad) ? :broad : :narrow
        end
      end

      def legal_tile_rotation?(corp, hex, tile)
        connection_directions = graph.connected_hexes(corp).find { |k, _| k.id == hex.id }[1]
        connection_directions.each do |dir|
          connecting_path = tile.paths.find { |p| p.exits.include?(dir) }
          next unless connecting_path

          connecting_track = connecting_path.track
          neighboring_tile = hex.neighbors[dir].tile
          neighboring_path = neighboring_tile.paths.find { |p| p.exits.include?(Engine::Hex.invert(dir)) }
          return true if neighboring_path.tracks_match(connecting_track)
        end
        false
      end

      def can_par?(corporation, _parrer)
        !corporation.ipoed && corporation.next_to_par && !corporation.closed_recently
      end

      def upgrade_cost(tile, hex, entity)
        return 0 if tile.upgrades.empty?

        upgrade = tile.upgrades[0]
        case new_track(tile, hex.tile)
        when :dual
          upgrade.cost
        when :narrow
          @log << "#{entity.name} pays 1/4 cost for narrow gauge track"
          upgrade.cost / 4
        when :broad
          ability = entity.all_abilities.find { |a| a.type == :tile_discount }
          discount = ability ? upgrade.cost / 2 : 0
          if discount.positive?
            @log << "#{entity.name} receives a discount of "\
                    "#{format_currency(discount)} from "\
                    "#{ability.owner.name}"
          end
          upgrade.cost - discount
        end
      end

      def event_green_par!
        @log << "-- Event: #{EVENTS_TEXT['green_par'][1]} --"
        stock_market.enable_par_price(144)
        update_cache(:share_prices)
      end

      def event_brown_par!
        @log << "-- Event: #{EVENTS_TEXT['brown_par'][1]} --"
        stock_market.enable_par_price(216)
        update_cache(:share_prices)
      end

      def event_earthquake!
        @log << '-- Event: Messina Earthquake --'
        # Remove tile from Messina

        # Remove from game tokens on Messina

        # If Garibaldi's only token removed, close Garibaldi

        # Messina cannot be upgraded until after next stock round
      end
    end
  end
end
