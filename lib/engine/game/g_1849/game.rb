# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'corporation'
require_relative 'share_pool'
require_relative 'stock_market'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1849
      class Game < Game::Base
        include_meta(G1849::Meta)
        include Entities
        include Map
        register_colors(black: '#000000',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#ff0000',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a',
                        goldenrod: '#f9b231')

        CURRENCY_FORMAT_STR = 'L.%d'

        BANK_CASH = 7760

        CERT_LIMIT = { 3 => 12, 4 => 11, 5 => 9 }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300 }.freeze

        MARKET = [
          %w[72 83 95 107 120 133 147 164 182 202 224 248 276 306u 340u 377e],
          %w[63 72 82 93 104 116 128 142 158 175 195 216z 240 266u 295u 328u],
          %w[57 66 75 84 95 105 117 129 144x 159 177 196 218 242u 269u 298u],
          %w[54 62 71 80 90 100p 111 123 137 152 169 187 208 230],
          %w[52 59 68p 77 86 95 106 117 130 145 160 178 198],
          %w[47 54 62 70 78 87 96 107 118 131 146 162],
          %w[41 47 54 61 68 75 84 93 103 114 127],
          %w[34 39 45 50 57 63 70 77 86 95],
          %w[27 31 36 40 45 50 56],
          %w[0c 24 27 31],
        ].freeze

        PHASES = [
          {
            name: '4H',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['gray_uses_white'],
          },
          {
            name: '6H',
            on: '6H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[gray_uses_white can_buy_companies],
          },
          {
            name: '8H',
            on: '8H',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[gray_uses_gray can_buy_companies],
          },
          {
            name: '10H',
            on: '10H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[gray_uses_gray can_buy_companies],
          },
          {
            name: '12H',
            on: '12H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['gray_uses_black'],
          },
          {
            name: '16H',
            on: '16H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[gray_uses_black blue_zone],
          },
        ].freeze

        TRAINS = [{ name: '4H', num: 4, distance: 4, price: 100, rusts_on: '8H' },
                  {
                    name: '6H',
                    distance: 6,
                    price: 200,
                    rusts_on: '10H',
                    events: [{ 'type' => 'green_par' }],
                  },
                  { name: '8H', distance: 8, price: 350, rusts_on: '16H' },
                  {
                    name: '10H',
                    num: 2,
                    distance: 10,
                    price: 550,
                    events: [{ 'type' => 'brown_par' }],
                  },
                  {
                    name: '12H',
                    num: 1,
                    distance: 12,
                    price: 800,
                    events: [{ 'type' => 'close_companies' }, { 'type' => 'earthquake' }],
                  },
                  { name: '16H', distance: 16, price: 1100 },
                  { name: 'R6H', num: 2, available_on: '16H', distance: 6, price: 350 }].freeze

        CAPITALIZATION = :incremental

        BANKRUPTCY_ALLOWED = true

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or, stock_market: :after_max_operates }.freeze

        GAME_END_REASONS_TIMING_TEXT = Base::GAME_END_REASONS_TIMING_TEXT.merge(
          after_max_operates: 'After corporation finishes operating'
        ).freeze

        CLOSED_CORP_RESERVATIONS_REMOVED = false

        EBUY_OTHER_VALUE = false
        HOME_TOKEN_TIMING = :float
        SELL_AFTER = :operate
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_per_10
        POOL_SHARE_DROP = :one
        CERT_LIMIT_COUNTS_BANKRUPTED = true

        MARKET_TEXT = Base::MARKET_TEXT.merge(phase_limited: 'Can only enter during phase 16',
                                              par: 'Yellow phase par',
                                              par_1: 'Green phase par',
                                              par_2: 'Brown phase par').freeze
        STOCKMARKET_COLORS = {
          par: :yellow,
          par_1: :green,
          par_2: :brown,
          endgame: :orange,
          close: :purple,
          phase_limited: :blue,
        }.freeze

        ASSIGNMENT_TOKENS = {
          CNM: '/icons/1849/cnm_token.svg',
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          green_par: ['144 Par Available',
                      'Corporations may now par at 144 (in addition to 67 and 100)'],
          brown_par: ['216 Par Available',
                      'Corporations may now par at 216 (in addition to 67, 100, and 144)'],
          earthquake: ['Messina Earthquake',
                       'Messina (B14) downgraded to yellow, tokens removed from game.
                        Cannot be upgraded until after next stock round']
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          blue_zone: ['Blue Zone Available', 'Corporation share prices can enter the blue zone'],
          gray_uses_white: ['White Revenues', 'Gray locations use white revenue values'],
          gray_uses_gray: ['Gray Revenues', 'Gray locations use gray revenue values'],
          gray_uses_black: ['Black Revenues', 'Gray locations use black revenue values']
        ).freeze

        GRAY_REVENUE_CENTERS =
          {
            C1:
              {
                '4H': 20,
                '6H': 20,
                '8H': 30,
                '10H': 30,
                '12H': 40,
                '16H': 40,
              },
            E1:
              {
                '4H': 20,
                '6H': 20,
                '8H': 30,
                '10H': 30,
                '12H': 40,
                '16H': 40,
              },
            C15:
              {
                '4H': 10,
                '6H': 10,
                '8H': 30,
                '10H': 30,
                '12H': 90,
                '16H': 90,
              },
            M9:
              {
                '4H': 20,
                '6H': 20,
                '8H': 30,
                '10H': 30,
                '12H': 40,
                '16H': 40,
              },
          }.freeze

        CORP_CHOOSES_HOME = 'AFG'
        CORP_CHOOSES_HOME_HEXES = %w[C1 H8 M9 M11 B14].freeze
        PORT_HEXES = %w[a12 A5 L14 N8].freeze
        SMS_HEXES = %w[B14 C1 C5 E1 H12 J6 M9 M13].freeze

        IFT_BUFFER = 3

        attr_accessor :swap_choice_player, :swap_location, :swap_other_player, :swap_corporation,
                      :loan_choice_player, :player_debts,
                      :max_value_reached,
                      :old_operating_order, :moved_this_turn

        def option_delay_ift?
          @optional_rules&.include?(:delay_ift)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def sms_hexes
          SMS_HEXES
        end

        def game_ending_description
          _, after = game_end_check
          return unless after

          if after == :full_or
            return "Bank Broken : Game Ends at conclusion of #{round_end.short_name} #{turn}.#{operating_rounds}"
          end

          'Company hit max stock value : Game Ends after it operates'
        end

        def end_now?(after)
          return false unless after

          return false if after == :after_max_operates

          @round.round_num == @operating_rounds
        end

        def game_end_check
          return %i[stock_market after_max_operates] if @max_value_reached

          return %i[bank full_or] if @bank.broken?

          nil
        end

        def price_movement_chart
          [
            ['Dividend', 'Share Price Change'],
            ['0 or withheld', '1 ←'],
            ['< share price', 'none'],
            ['≥ share price', '1 →'],
          ]
        end

        def setup
          setup_companies
          afg # init afg helper
          remove_corp if @players.size == 3
          @corporations[0].next_to_par = true

          @available_par_groups = %i[par]

          @player_debts = Hash.new { |h, k| h[k] = 0 }
          @moved_this_turn = []
        end

        def setup_companies
          rsa = company_by_id('RSA')
          rsa_share = rsa.all_abilities[0].shares.first

          # RSA closes on train buy
          rsa.add_ability(Ability::Close.new(
            type: :close,
            when: 'bought_train',
            corporation: rsa_share.corporation.name,
          ))

          companies.each { |c| c.min_price = 1 }
        end

        def remove_corp
          removed = @corporations.pop
          @log << "Removed #{removed.name}"
          return if removed == afg

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
          raise NotImplementedError unless corporation.name == self.class::CORP_CHOOSES_HOME

          self.class::CORP_CHOOSES_HOME_HEXES.map { |coord| hex_by_id(coord) }.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def init_stock_market
          sm = G1849::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                      multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
          sm.game = self
          sm
        end

        def init_corporations(stock_market)
          min_price = stock_market.par_prices.map(&:price).min

          corporations = self.class::CORPORATIONS.map do |corporation|
            G1849::Corporation.new(
              min_price: min_price,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(corporation_opts),
            )
          end

          corporations.sort_by! { rand }
          if option_delay_ift?
            ift_idx = corporations.index { |corp| corp.id == 'IFT' }
            if ift_idx && ift_idx < IFT_BUFFER
              # Not the algorithm in the rules but it produces the same distribution
              corporations[ift_idx], corporations[IFT_BUFFER] = corporations[IFT_BUFFER], corporations[ift_idx]
            end
          end

          corporations
        end

        def init_share_pool
          G1849::SharePool.new(self)
        end

        def update_garibaldi
          return unless afg && !afg.slot_open && !home_token_locations(afg).empty?

          afg.slot_open = true
          afg.closed_recently = true
          @log << 'AFG now has a token spot available and can be opened in the next stock round.'
        end

        def remove_rsa_abilities(corporation)
          rsa = company_by_id('RSA')

          share_ability = rsa.all_abilities.find { |abil| abil.type == :shares }
          rsa.remove_ability(share_ability) if share_ability && share_ability.shares.first.corporation == corporation

          close_ability = rsa.all_abilities.find { |abil| abil.type == :close }
          rsa.remove_ability(close_ability) if close_ability && close_ability.corporation == corporation.name
        end

        def close_corporation(corporation, quiet: false)
          remove_rsa_abilities(corporation)
          super
          corporation = reset_corporation(corporation)
          @afg = corporation if corporation.id == self.class::CORP_CHOOSES_HOME
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

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1849::Step::CompanyPendingPar,
            Engine::Step::WaterfallAuction,
          ])
        end

        def stock_round
          G1849::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1849::Step::HomeToken,
            G1849::Step::SwapChoice,
            G1849::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1849::Round::Operating.new(self, [
            G1849::Step::LoanChoice,
            G1849::Step::Bankrupt,
            G1849::Step::SwapChoice,
            Engine::Step::BuyCompany,
            G1849::Step::SMSTeleport,
            G1849::Step::Assign,
            G1849::Step::Track,
            G1849::Step::Token,
            Engine::Step::Route,
            G1849::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1849::Step::BuyTrain,
            G1849::Step::IssueShares,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def next_round!
          super
          @corporations.each { |c| c.sms_hexes = nil }
        end

        def track_type(paths)
          types = paths.map(&:track).uniq
          raise GameError, 'Can only change track type at station.' if types.include?(:broad) && types.include?(:narrow)

          if types.include?(:narrow)
            :narrow
          elsif types.include?(:broad)
            :broad
          else
            :dual
          end
        end

        def hex_edge_cost(conn, train)
          track = track_type(conn[:paths])
          edges = conn[:paths].each_cons(2).sum do |a, b|
            a.hex == b.hex ? 0 : 1
          end
          if train.name == 'R6H'
            track == :broad ? edges * 2 : edges
          else
            track == :narrow ? edges * 2 : edges
          end
        end

        def route_distance(route)
          route.chains.sum { |conn| hex_edge_cost(conn, route.train) }
        end

        def route_distance_str(route)
          "#{route_distance(route)}H"
        end

        def check_distance(route, _visits)
          limit = route.train.distance
          distance = route_distance(route)
          raise GameError, "#{distance} is too many hex edges for #{route.train.name} train" if distance > limit
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
          return gray_revenue(stop) if GRAY_REVENUE_CENTERS.key?(stop.hex.id)

          stop.route_revenue(phase, train)
        end

        def gray_revenue(stop)
          GRAY_REVENUE_CENTERS[stop.hex.id][@phase.name]
        end

        def reorder_corps
          just_moved = @moved_this_turn.uniq
          @moved_this_turn = []
          same_spot =
            @corporations
              .select(&:floated?)
              .group_by(&:share_price)
              .select { |_, v| v.size > 1 }
          return if same_spot.empty?

          same_spot.each do |sp, corps|
            current_order = corps.sort
            moved, unmoved = current_order.partition { |c| just_moved.include?(c) }
            moved_ordered = moved.sort_by { |c| old_operating_order.index(c) }
            new_order = unmoved + moved_ordered
            next if current_order == new_order

            @log << 'Updating operating order for sold (and moved) corporations now
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

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          super && (from.hex.id != 'B14' || @messina_upgradeable)
        end

        def legal_tile_rotation?(corp, hex, tile)
          return true if corp.sms_hexes

          return true if hex.tile.cities.any? { |city| city.tokened_by?(corp) }

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

        def upgrade_cost(tile, hex, entity, _spender)
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
          @available_par_groups << :par_1
          update_cache(:share_prices)
        end

        def event_brown_par!
          @log << "-- Event: #{EVENTS_TEXT[:brown_par][1]} --"
          @available_par_groups << :par_2
          update_cache(:share_prices)
        end

        def event_earthquake!
          @log << '-- Event: Messina Earthquake --'
          messina = @hexes.find { |h| h.id == 'B14' }

          city = messina.tile.cities[0]

          # If Garibaldi's only token removed, close Garibaldi
          if afg && city.tokened_by?(afg) && afg.placed_tokens.one?
            @log << '-- AFG loses only token, closing. --'
            @round.force_next_entity! if @round.current_entity == afg
            close_corporation(afg)
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

          # Some companies might no longer have valid routes
          @graph.clear_graph_for_all
        end

        def bank_sort(corporations)
          corporations
        end

        def player_value(player)
          player.value - @player_debts[player]
        end

        def par_prices
          @stock_market.share_prices_with_types(@available_par_groups)
        end
      end
    end
  end
end
