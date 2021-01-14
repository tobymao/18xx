# frozen_string_literal: true

require_relative '../config/game/g_1849'
require_relative 'base'
require_relative '../g_1849/corporation'
require_relative '../g_1849/share_pool'
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

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Sicily'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/206628/1849-rules'
      GAME_DESIGNER = 'Federico Vellani'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849'

      CAPITALIZATION = :incremental

      BANKRUPTCY_ALLOWED = true

      CLOSED_CORP_RESERVATIONS = :remain

      EBUY_OTHER_VALUE = false
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :operate
      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :down_per_10
      POOL_SHARE_DROP = :one

      MARKET_TEXT = Base::MARKET_TEXT.merge(phase_limited: 'Can only enter during phase 16').freeze
      STOCKMARKET_COLORS = {
        par: :yellow,
        endgame: :orange,
        close: :purple,
        phase_limited: :blue,
      }.freeze

      ASSIGNMENT_TOKENS = {
        'CNM': '/icons/1849/cnm_token.svg',
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
        'gray_uses_white': ['White Revenues', 'Gray locations use white revenue values'],
        'gray_uses_gray': ['Gray Revenues', 'Gray locations use gray revenue values'],
        'gray_uses_black': ['Black Revenues', 'Gray locations use black revenue values']
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
      SMS_HEXES = %w[B14 C1 C5 H12 J6 M9 M13].freeze

      attr_accessor :swap_choice_player, :swap_other_player, :swap_corporation,
                    :loan_choice_player, :player_debts,
                    :max_value_reached,
                    :old_operating_order, :sold_this_turn

      def sms_hexes
        SMS_HEXES
      end

      def game_ending_description
        _, after = game_end_check
        return unless after

        return "Bank Broken : Game Ends at conclusion of
                #{round_end.short_name} #{turn}.#{operating_rounds}" if after == :full_or
        'Company hit max stock value : Game Ends after it operates'
      end

      def end_now?(after)
        return false unless after

        return false if after == :after_max_operates

        @round.round_num == @operating_rounds
      end

      def game_end_check
        return %i[custom after_max_operates] if @max_value_reached

        return %i[bank full_or] if @bank.broken?

        nil
      end

      def setup
        @corporations.sort_by! { rand }
        setup_companies
        remove_corp if @players.size == 3
        @corporations[0].next_to_par = true

        @player_debts = Hash.new { |h, k| h[k] = 0 }
        @sold_this_turn = []
      end

      def setup_companies
        # RSA to close on train buy
        rsa = company_by_id('RSA')
        rsa_share = rsa.all_abilities[0].shares.first
        rsa.add_ability(Ability::Close.new(
          type: :close,
          when: 'bought_train',
          corporation: rsa_share.corporation.name,
        ))

        # RSA corp to be first
        index = @corporations.index { |corp| corp.id == rsa_share.corporation.id }
        @corporations[0], @corporations[index] = @corporations[index], @corporations[0]

        # min_price == 1
        companies.each { |c| c.min_price = 1 }
      end

      def remove_corp
        removed = @corporations.pop
        @log << "Removed #{removed.name}"
        return if removed.name == 'AFG'

        hex_by_id(removed.coordinates).tile.city_towns.first.remove_reservation!(removed)
        @log << "Removed token reservation at #{removed.coordinates}"
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

        @corporations[index + 1].next_to_par = true unless @corporations.last == corporation
        place_home_token(corporation) if @round.stock?
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

      def init_share_pool
        Engine::G1849::SharePool.new(self)
      end

      def update_garibaldi
        afg = @corporations.find { |c| c.name == 'AFG' }
        return unless afg && !afg.slot_open && !home_token_locations(afg).empty?

        afg.slot_open = true
        afg.closed_recently = true
        @log << 'AFG now has a token spot available and can be opened in the next stock round.'
      end

      def close_corporation(corporation, quiet: false)
        super
        corporation = reset_corporation(corporation)
        @afg = corporation if corporation.id == 'AFG'
        hex_by_id(corporation.coordinates).tile.add_reservation!(corporation, 0) unless corporation == afg
        @corporations << corporation
        corporation.closed_recently = true
        index = @corporations.index(corporation)

        # let this corp skip AFG in line if AFG is blocked from opening
        unless @corporations[index - 1].slot_open
          @corporations[index - 1].next_to_par = false
          @corporations[index - 1], @corporations[index] = @corporations[index], @corporations[index - 1]
        end
        corporation.next_to_par = true if @corporations[index - 1].floated?
        update_garibaldi
      end

      def float_str(entity)
        "#{format_currency(entity.token_fee)} token fee" if entity.corporation?
      end

      def new_stock_round
        @corporations.each { |c| c.closed_recently = false }
        @messina_upgradeable = true
        super
      end

      def afg
        @afg ||= @corporations.find { |corp| corp.id == 'AFG' }
      end

      def stock_round
        Round::G1849::Stock.new(self, [
          Step::DiscardTrain,
          Step::G1849::HomeToken,
          Step::G1849::SwapChoice,
          Step::G1849::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::G1849::Operating.new(self, [
          Step::G1849::LoanChoice,
          Step::G1849::Bankrupt,
          Step::G1849::SwapChoice,
          Step::BuyCompany,
          Step::G1849::SMSTeleport,
          Step::G1849::Assign,
          Step::G1849::Track,
          Step::G1849::Token,
          Step::Route,
          Step::G1849::Dividend,
          Step::DiscardTrain,
          Step::G1849::BuyTrain,
          Step::G1849::IssueShares,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def next_round!
        super
        @corporations.each { |c| c.sms_hexes = nil }
      end

      def track_type(paths)
        types = paths.map(&:track).uniq
        raise GameError, 'Can only change track type at station.' if types.include?(:broad) && types.include?(:narrow)

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
        raise GameError, "#{cost} is too many hex edges for #{route.train.name} train" if cost > limit
      end

      def check_other(route)
        return unless (route.stops.map(&:hex).map(&:id) & PORT_HEXES).any?

        raise GameError, 'Route must include two non-port stops.' unless route.stops.size > 2
      end

      def revenue_for(route, stops)
        total = stops.sum { |stop| stop_revenue(stop, route.phase, route.train) }
        total + cnm_bonus(route.corporation, stops)
      end

      def cnm_bonus(corp, stops)
        corp.assigned?('CNM') && stops.map(&:hex).find { |hex| hex.assigned?('CNM') } ? 20 : 0
      end

      def stop_revenue(stop, phase, train)
        return gray_revenue(stop) if GRAY_REVENUE_CENTERS.keys.include?(stop.hex.id)

        stop.route_revenue(phase, train)
      end

      def gray_revenue(stop)
        GRAY_REVENUE_CENTERS[stop.hex.id][@phase.name]
      end

      def buying_power(entity, **)
        entity.cash
      end

      def reorder_corps
        just_sold = @sold_this_turn.uniq
        @sold_this_turn = []
        same_spot =
          @corporations
            .select(&:floated?)
            .group_by(&:share_price)
            .select { |_, v| v.size > 1 }
        return if same_spot.empty?

        same_spot.each do |sp, corps|
          current_order = corps.sort
          sold, unsold = current_order.partition { |c| just_sold.include?(c) }
          sold_ordered = sold.sort_by { |c| old_operating_order.index(c) }
          new_order = unsold + sold_ordered
          next if current_order == new_order

          @log << 'Updating operating order for sold corporations
                    on same share value space to maintain relative order before sales.'
          @log << "#{current_order.map(&:name)} --> #{new_order.map(&:name)}"
          sp.corporations.clear
          sp.corporations.concat(new_order)
        end
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

      def dumpable_on(bundle, would_be_pres)
        return true unless bundle.presidents_share
        return false unless would_be_pres

        owner_percent = bundle.owner.percent_of(bundle.corporation)
        other_percent = would_be_pres.percent_of(bundle.corporation)

        owner_after_percent = owner_percent - bundle.percent

        if other_percent == 20 && would_be_pres.certs_of(bundle.corporation).one?
          return true if owner_after_percent.zero?

          owner_percent > 20 && owner_after_percent == 10
        end

        owner_after_percent < 20 && other_percent > owner_after_percent
      end

      def find_would_be_pres(player, corporation)
        sorted_candidates =
          @players
            .select { |p| p.id != player.id && p.percent_of(corporation) >= 20 }
            .sort_by { |p| p.percent_of(corporation) }
            .reverse!
        return nil if sorted_candidates.empty?

        max_percent = sorted_candidates.first.percent_of(corporation)
        sorted_candidates
          .take_while { |c| c.percent_of(corporation) == max_percent }
          .min_by { |c| share_pool.distance(player, c) }
      end

      def bundles_for_corporation(share_holder, corporation, shares: nil)
        return [] unless corporation.ipoed

        shares = (shares || share_holder.shares_of(corporation))

        bundles = (1..shares.size).flat_map do |n|
          shares.combination(n).to_a.map { |ss| Engine::ShareBundle.new(ss) }
        end

        bundles = bundles.uniq do |b|
          [b.shares.count { |s| s.percent == 10 },
           b.presidents_share ? 1 : 0,
           b.shares.find(&:last_cert) ? 1 : 0]
        end

        (if corporation.president?(share_holder)
           bundles << Engine::ShareBundle.new(corporation.presidents_share, 10)
           would_be_pres = find_would_be_pres(share_holder, corporation)
           bundles.select { |b| dumpable_on(b, would_be_pres) }
         else
           bundles
         end).sort_by(&:percent)
      end

      def last_cert_last?(bundle)
        bundle = bundle.to_bundle
        last_cert = bundle.shares.find(&:last_cert)
        return true unless last_cert

        location = bundle.owner.share_pool? ? share_pool.shares_of(bundle.corporation) : bundle.corporation.ipo_shares
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

      def upgrades_to?(from, to, special = false)
        super && (from.hex.id != 'B14' || @messina_upgradeable)
      end

      def legal_tile_rotation?(corp, hex, tile)
        return true if corp.sms_hexes

        connection_directions = graph.connected_hexes(corp).find { |k, _| k.id == hex.id }[1]
        ever_not_nil = false # to permit teleports and SFA/AFG initial tile lay
        connection_directions.each do |dir|
          connecting_path = tile.paths.find { |p| p.exits.include?(dir) }
          next unless connecting_path

          neighboring_tile = hex.neighbors[dir].tile
          neighboring_path = neighboring_tile.paths.find { |p| p.exits.include?(Engine::Hex.invert(dir)) }
          if neighboring_path
            ever_not_nil = true
            return true if connecting_path.tracks_match?(neighboring_path, dual_ok: true)
          end
        end
        !ever_not_nil
      end

      def can_par?(corp, _parrer)
        !corp.ipoed && corp.next_to_par && !corp.closed_recently && corp.slot_open
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
        @log << "-- Event: #{EVENTS_TEXT[:green_par][1]} --"
        stock_market.enable_par_price(144)
        update_cache(:share_prices)
      end

      def event_brown_par!
        @log << "-- Event: #{EVENTS_TEXT[:brown_par][1]} --"
        stock_market.enable_par_price(216)
        update_cache(:share_prices)
      end

      def event_earthquake!
        @log << '-- Event: Messina Earthquake --'
        messina = @hexes.find { |h| h.id == 'B14' }

        city = messina.tile.cities[0]

        # If Garibaldi's only token removed, close Garibaldi
        if (garibaldi = @corporations.find { |c| c.name == 'AFG' })
          if city.tokened_by?(garibaldi) && garibaldi.placed_tokens.one?
            @log << '-- AFG loses only token, closing. --'
            close_corporation(garibaldi)
          end
        end

        # Remove from game tokens on Messina
        @log << '-- Removing tokens from game. --'
        city.tokens.each { |t| t&.destroy! }

        # Remove tile from Messina
        @log << '-- Returning Messina to yellow. --'
        messina.lay_downgrade(messina.original_tile)

        # Messina cannot be upgraded until after next stock round
        @log << '-- Messina cannot be upgraded until after the next stock round. --'
        @messina_upgradeable = false
      end

      def bank_sort(corporations)
        corporations
      end

      def player_value(player)
        player.value - @player_debts[player]
      end
    end
  end
end
